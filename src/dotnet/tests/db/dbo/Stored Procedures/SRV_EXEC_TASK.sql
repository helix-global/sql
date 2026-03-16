

-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2025-02-14
-- Description: Execute specified server task.
-- =============================================
-- KB5247:2025-02-04: Initial Update.
-- KB5186:2025-04-03: Added optional @UserID.
CREATE PROCEDURE [dbo].[SRV_EXEC_TASK]
  @TaskID int = null,
  @TaskLabel nvarchar(max) = null,
  @Options nvarchar(max) = null,
  @UserID int = 0
as
begin
  set nocount on;
  if isnull(@TaskID,0) = 0
  begin
    if @TaskLabel is not null
    begin
      select top 1
        @TaskID=[a].[OID]
      from [dbo].[SRV_TASK] [a] with(nolock)
      where [a].[LABL] like @TaskLabel
    end
  end
  if isnull(@TaskID,0) <> 0
  begin
    declare @OptionsE table ([OPTION] nvarchar(max))
    declare @OptionsT table ([OPTION] nvarchar(max))
    insert into @OptionsE select [OPTION] from [dbo].[COM_OPT_SPLIT](@Options)
    insert into @OptionsT
      select
        [b].[OPTION]
      from [dbo].[SRV_TASK] [a] with(nolock)
        cross apply [dbo].[COM_OPT_SPLIT]([a].[OPTIONS]) [b]
      where [a].[OID]=@TaskID

    declare @TaskND datetime = null
    select
      @TaskND=[a].[NEXTDATE]
    from [dbo].[SRV_TASK_STATUS] [a] with(nolock)
    where [a].[TASK]=@TaskID

    if not exists(select * from @OptionsE where [OPTION] like 'ForceUpdate')
    begin
      if (@TaskND is not null) and (@TaskND > getdate())
      begin
        print N'Missing due to task status.'
        return
      end
    end

    declare @stmt nvarchar(max) = null
    select
       @stmt=[a].[SQLSTMT]
      ,@TaskLabel=[a].[LABL]
    from [dbo].[SRV_TASK] [a] with(nolock)
    where [a].[OID]=@TaskID

    if @stmt is not null
    begin
      declare @params nvarchar(max)='@TaskLabel nvarchar(max),@UserID int'
      exec sp_executesql @stmt,@params
        ,@TaskLabel=@TaskLabel
        ,@UserID=@UserID
    end

    declare @RepeatTaskEveryI int
    declare @RepeatTaskEveryS nvarchar(max)
    select top 1
      @RepeatTaskEveryS=substring([a].[OPTION],17,len([a].[OPTION])-16)
    from @OptionsT [a]
    where [a].[OPTION] like 'RepeatTaskEvery=%'

    set @RepeatTaskEveryI=datediff(mi,'1900-01-01T00:00:00',[dbo].[COM_TIME_PARSE](cast(@RepeatTaskEveryS as nvarchar(64))))
    set @RepeatTaskEveryI=isnull(@RepeatTaskEveryI,30)

    merge [dbo].[SRV_TASK_STATUS] [a]
    using
      (
      select
        @TaskID    [TASK]
        ,getdate() [LASTDATE]
        ,dateadd(mi,@RepeatTaskEveryI,getdate()) [NEXTDATE]
      ) [b] on [b].[TASK]=[a].[TASK]
    when not matched then
      insert ([TASK],[LASTDATE],[NEXTDATE]) values ([b].[TASK],[b].[LASTDATE],[b].[NEXTDATE])
    when matched then
      update set
         [LASTDATE]=[b].[LASTDATE]
        ,[NEXTDATE]=[b].[NEXTDATE];
  end
end