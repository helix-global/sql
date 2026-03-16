
-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-08-19
-- Description: Returns related operation identifier for specified failure report.
-- =============================================
-- KB4741:2024-08-19: Initial update.
create function [dbo].[FC_REPORT_RELATED_OPERID](@FailureReportID int,@Options nvarchar(max))
returns int
as
begin
  if @FailureReportID is null return null
  declare @OperID int
  declare @ParentOperID int

  select top 1
     @OperID = [a].[ID]
    ,@ParentOperID = [a].[PARENTID]
  from [dbo].[PR_OPERATION] [a] with(nolock)
  where [a].[FAILUREREPORTID] = @FailureReportID
  order by [a].[ID]

  if @Options is not null
    if len(@Options) > 0
    begin
      declare @RecursionLevel int = 10
      declare @OptionsT table([OPTION] nvarchar(max))
      insert into @OptionsT select [a].[OPTION] from [dbo].[COM_OPT_SPLIT](@Options) [a]

      if exists(select * from @OptionsT [a] where [a].[OPTION] like N'RecursiveByParentOperation')
      begin
        if exists(select * from @OptionsT [a] where [a].[OPTION] like N'Troubleshooting') set @RecursionLevel = 1
        while (@ParentOperID is not null) and (@RecursionLevel > 0)
        begin
          set @OperID = @ParentOperID
          set @ParentOperID = null

          select top 1
            @ParentOperID = [a].[PARENTID]
          from [dbo].[PR_OPERATION] [a] with(nolock)
          where [a].[ID] = @OperID
          order by [a].[ID]
          set @RecursionLevel=@RecursionLevel-1
        end
      end
    end
  return @OperID
end