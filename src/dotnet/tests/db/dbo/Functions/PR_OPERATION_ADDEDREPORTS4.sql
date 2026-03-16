-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-01-26
-- Description: Returns identifiers of [PR_REPORT] instances associated with specified operation data as semicolon delimited string.
--              Retrieves data from [dbo].[PR_OPERATION_ADDEDREPORTS3] and adds data for the preparation operation.
-- =============================================
-- KB4488:2024-01-26: Initial update.
create function [dbo].[PR_OPERATION_ADDEDREPORTS4](@OperID int, @OperState int, @OperTypeID int, @DeviceID int, @DevCmpl datetime, @RevID int, @ModelID int, @MTID int, @EqID int, @EqModelID int)
returns nvarchar(max)
as
begin
  declare @Identifiers table([ID] int, unique clustered ([ID]))
  insert into @Identifiers
    select distinct cast([ITEM] as int) from [dbo].[COM_STR2TABLE_STR_DELIM](
      [dbo].[PR_OPERATION_ADDEDREPORTS3](
        @OperID,@OperState,@OperTypeID,
        @DeviceID,@DevCmpl,@RevID,@ModelID,
        @MTID,@EqID,@EqModelID),';')
    order by cast([ITEM] as int)

  merge @Identifiers [i]
  using
    (
    select [a].[ID]
    from [dbo].[PR_OP_PRE_REPORTS](@OperId) [a]
    ) [a] on [i].[ID]=[a].[ID]
  when not matched then
    insert ([ID]) values ([a].[ID]);

  declare @res nvarchar(max)
  select
     @res=[dbo].[GROUP_CONCAT_D](cast([a].[ID] as nvarchar(max)),';')
  from @Identifiers [a]

  if LEN(@res) = 0 return null
  return @res
end