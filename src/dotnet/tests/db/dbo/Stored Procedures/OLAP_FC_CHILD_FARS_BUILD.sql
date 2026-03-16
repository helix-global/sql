-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-06-25
-- Description: Builds [dbo].[FC_GETCHILD_FARS] dimension tables ([OLAP_JOB_RESULT_FC_GETCHILD_FARS]).
-- =============================================
-- KB4660:2024-06-26: Initial update.
create procedure [dbo].[OLAP_FC_CHILD_FARS_BUILD]
as
begin
  set nocount on;

  declare @JobND datetime = null
  select
    @JobND=[a].[NEXTDATE]
  from [dbo].[OLAP_JOB_STATUS] [a] with(nolock)
  where [a].[JOBID]='f0baad50-c61a-469f-a867-e802bf366601'

  if (@JobND is not null) and (@JobND > getdate())
  begin
    print N'Missing due to job status.'
    return
  end

  declare @FullT table([ID] int identity,[PARENTID] int,[CHILDID] int,[S_DT] datetime
    index [IX-1] clustered ([PARENTID]),
    index [IX-2] unique ([PARENTID],[CHILDID]),
    index [IX-3] unique ([PARENTID],[CHILDID],[S_DT]));

  with [A]([ID],[PARENTID],[LEVEL])
    as
    (
    select
       [a].[ID]
      ,[a].[PARENTID]
      ,0 [LEVEL]
    from [dbo].[FC_REPORT] [a] with(nolock)
    where [a].[PARENTID] is not null
    union all
    select
       [a].[ID]
      ,[b].[PARENTID]
      ,[b].[LEVEL]+1 [LEVEL]
    from [dbo].[FC_REPORT] [a] with(nolock)
      inner join [A] [b] on [b].[ID]=[a].[PARENTID]
    where [b].[LEVEL]<100
      and [a].[ID]<>[a].[PARENTID]
    )
  insert into @FullT
    select distinct
       [a].[PARENTID]
      ,[a].[ID]
      ,isnull([b].[S_MDT],[b].[S_CDT])
    from [A] [a]
      inner join [dbo].[FC_REPORT] [b] with(nolock) on [b].[ID]=[a].[ID]
  option(maxrecursion 0);

  if not exists(select * from [dbo].[OLAP_JOB_RESULT_FC_GETCHILD_FARS])
  begin
    -- Initial update
    insert into [dbo].[OLAP_JOB_RESULT_FC_GETCHILD_FARS]([FC_REPORT_PARENTID],[FC_REPORT_CHILDID],[FC_REPORT_S_DT])
      select
         [a].[PARENTID]
        ,[a].[CHILDID]
        ,[a].[S_DT]
      from @FullT [a]
  end else
  begin
    declare @DiffD table([PARENTID] int,unique clustered ([PARENTID]))
    insert into @DiffD
      select distinct
        [b].[FC_REPORT_PARENTID]
      from @FullT [a]
        right join [dbo].[OLAP_JOB_RESULT_FC_GETCHILD_FARS] [b] on [b].[FC_REPORT_PARENTID]=[a].[PARENTID] and [b].[FC_REPORT_CHILDID]=[a].[CHILDID] and [b].[FC_REPORT_S_DT]=[a].[S_DT]
      where [a].[ID] is null
    if exists(select * from @DiffD)
    begin
      print N'Non-existing records found'
      print N'  Deleting non-existing records'
      delete from [a]
      from [dbo].[OLAP_JOB_RESULT_FC_GETCHILD_FARS] [a]
        inner join @DiffD [b] on [b].[PARENTID]=[a].[FC_REPORT_PARENTID]
    end

    declare @DiffU table([PARENTID] int,unique clustered ([PARENTID]))
    insert into @DiffU
      select distinct
        [a].[PARENTID]
      from @FullT [a]
        left join [dbo].[OLAP_JOB_RESULT_FC_GETCHILD_FARS] [b] on [b].[FC_REPORT_PARENTID]=[a].[PARENTID] and [b].[FC_REPORT_CHILDID]=[a].[CHILDID] and [b].[FC_REPORT_S_DT]=[a].[S_DT]
      where [b].[ID] is null
    if exists(select * from @DiffU)
    begin
      print N'Differences in existing records were found'
      print N'  Deleting changed records'
      delete from [a]
      from [dbo].[OLAP_JOB_RESULT_FC_GETCHILD_FARS] [a]
        inner join @DiffU [b] on [b].[PARENTID]=[a].[FC_REPORT_PARENTID]
      print N'  Inserting changed records'
      insert into [dbo].[OLAP_JOB_RESULT_FC_GETCHILD_FARS]
        select
           [a].[PARENTID]
          ,[a].[CHILDID]
          ,[a].[S_DT]
        from @FullT [a]
          inner join @DiffU [b] on [b].[PARENTID]=[a].[PARENTID]
    end
  end

  merge [dbo].[OLAP_JOB_STATUS] [a]
  using
    (
    select
      'f0baad50-c61a-469f-a867-e802bf366601' [JOBID]
      ,getdate() [LASTDATE]
      ,dateadd(mi,30,getdate()) [NEXTDATE]
    ) [b] on [b].[JOBID]=[a].[JOBID]
  when not matched then
    insert ([JOBID],[LASTDATE],[NEXTDATE]) values ([b].[JOBID],[b].[LASTDATE],[b].[NEXTDATE])
  when matched then
    update set
       [LASTDATE]=[b].[LASTDATE]
      ,[NEXTDATE]=[b].[NEXTDATE];
end