CREATE function [dbo].[COM_REAL_WORKPERIODS2] (@dBeg datetime, @dEnd datetime, @calendar int, @wtID int, @emplID int)
returns @res table (
    DBEG datetime
   ,DEND datetime
  )
as 
begin

  declare @dEnd2 datetime = @dEnd
  
  /*KB3531*/
  if cast(@dBeg as date) <> cast(@dEnd as date)
  begin
     /* продлить до окончания ночной смены  + как-то учесть переработки после ночной смены */
     declare @turnEnd datetime
     select @turnEnd = max(A.WTURNEND)
     from dbo.COM_TURNS_AROUND(@dEnd,@wtID,@emplID) A
     where A.ACTIVATEDWTURN = 1
       and cast(A.WTURNBEG as date) = cast(@dBeg as date)
       and cast(A.WTURNEND as date) = cast(@dEnd as date)
       and ONLYONEWTURN = 0       

     if @turnEnd is not null and @turnEnd > @dEnd
     begin
        set @dEnd2 = dateadd(hour,2,@turnEnd)
     end
  end

  declare @vacationPeriods table (StartTime datetime, EndTime datetime, DiffMin int)

  insert into @vacationPeriods (StartTime, EndTime)
  select  
     dbo.COM_VACATION_DBEG3(ID)
    ,dbo.COM_VACATION_DEND3(ID)
  from COM_VACATION
  where --DBEG<=@dBeg and isnull(DEND,DBEG)>=@dEnd
    exists (select * from dbo.COM_DATE_PERIOD_OVERLAP(dbo.COM_VACATION_DBEG3(ID), dbo.COM_VACATION_DEND3(ID), @dBeg, @dEnd2))
    and EMPLID=@emplid
	  and S_S in (1000141,2130051) /*Approved*/

  declare @source as DatePeriodTableType
  declare @target as DatePeriodTableType
  
  insert into @source (BeginDate, EndDate)
  select P.DBEG, P.DEND 
  from dbo.COM_WORKPERIODS5(@dBeg,@dEnd2,@calendar,@wtID,@emplID) P
  
  insert into @target (BeginDate, EndDate)
  select P.StartTime, P.EndTime
  from @vacationPeriods P

  insert into @res (DBEG, DEND)
  select P.DBEG, P.DEND
  from dbo.COM_DATE_PERIOD_SUBSTRACT_TABLE(@source, @target) P
            
  return

end