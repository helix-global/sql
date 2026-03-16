--KB5377:2025-04-24: Refactored. Using [dbo].[PM_TIMETRACK_SUMDAY] instead of manual calculation.
CREATE procedure [dbo].[PM_CHECK_KB4770] @TrackId int, @UserID int
as
begin
  declare @Avail decimal(18,2)
  declare @Declared decimal(18,2)
  declare @DD date

  select
     @DD=[a].[DD]
    ,@Avail=[dbo].[COM_ATTENDANCE_TIME4](null,[a].[EMPLID],[a].[DD])
    ,@Declared = round([dbo].[PM_TIMETRACK_SUMDAY]([a].[EMPLID],[a].[DD],0)*60,0)
  from [dbo].[PM_TASK_TIME] [a] with(nolock)
  where [a].[ID]=@TrackId

  if @Avail > 0 and @Declared > @Avail
  begin
    declare @Message nvarchar(max)
    set @Message = '#WDeclared time in '+CONVERT(nvarchar,@DD,104)+' ('+CONVERT(nvarchar,@Declared)+' min.) is more than is available on this day ('+CONVERT(nvarchar,@Avail)+' min.)'
    print @Message
  end
end