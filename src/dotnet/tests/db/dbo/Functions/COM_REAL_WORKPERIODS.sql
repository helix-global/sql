-- KB5417:2025-05-13: Refactoring.
CREATE function [dbo].[COM_REAL_WORKPERIODS] (@DBeg datetime, @DEnd datetime, @Calendar int, @WTID int, @EmpID int)
returns @OutT table
  (
   [DBEG] datetime
  ,[DEND] datetime
  )
as
begin
  declare @VacationPeriods table ([StartTime] datetime,[EndTime] datetime,[DiffMin] int)
  insert into @VacationPeriods ([StartTime],[EndTime])
    select
       [dbo].[COM_VACATION_DBEG3]([a].[ID])
      ,[dbo].[COM_VACATION_DEND3]([a].[ID])
    from [dbo].[COM_VACATION] [a] with(nolock)
    where --DBEG<=@DBeg and isnull(DEND,DBEG)>=@DEnd
      exists (select * from [dbo].[COM_DATE_PERIOD_OVERLAP]([dbo].[COM_VACATION_DBEG3]([a].[ID]),[dbo].[COM_VACATION_DEND3]([a].[ID]),@DBeg,@DEnd))
      and [a].[EMPLID]=@EmpID
      and [a].[S_S] in (1000141,2130051) /*Approved*/

  declare @Source as DatePeriodTableType
  declare @Target as DatePeriodTableType

  insert into @Source ([BeginDate],[EndDate])
    select
       [a].[DBEG]
      ,[a].[DEND]
    from [dbo].[COM_WORKPERIODS5](@DBeg,@DEnd,@Calendar,@WTID,@EmpID) [a]

  insert into @Target ([BeginDate],[EndDate])
    select
       [a].[StartTime]
      ,[a].[EndTime]
    from @VacationPeriods [a]

  insert into @OutT ([DBEG],[DEND])
    select
       [a].[DBEG]
      ,[a].[DEND]
    from [dbo].[COM_DATE_PERIOD_SUBSTRACT_TABLE](@Source,@Target) [a]
  return
end