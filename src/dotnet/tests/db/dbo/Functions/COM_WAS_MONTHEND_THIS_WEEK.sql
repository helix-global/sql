CREATE function [dbo].[COM_WAS_MONTHEND_THIS_WEEK](@aDate datetime,@emplid int,@aMode int)
returns int as 
begin
  
  /* 
  возвращает 1 если на этой неделе, к которой принадлежит @aDate был конец предыдущего месяца 
  дата конца месяца при этом < @aDate либо дата конца месяца при этом = @aDate и рабочий день работника уже закончен
  */
  
  declare @PrevMonthEnd date
  declare @aDateDate date = cast(@aDate as date)
  
  set @PrevMonthEnd = dbo.COM_ENCODE_DATE(year(@aDateDate),month(@aDateDate),1)
  set @PrevMonthEnd = dateadd(day,-1,@PrevMonthEnd)
  
  if datepart(iso_week,@aDateDate) = datepart(iso_week,@PrevMonthEnd) 
  begin
     /*на этой неделе была смена месяца*/
  
     if @PrevMonthEnd < @aDateDate  /*смена месяца была в днях раньше*/
       return 1
  
  end
  
  if month(@aDateDate) <> month(dateadd(day,1,@aDateDate)) /*завтра другой месяц*/
  begin
    /*смена месяца сегодня*/
     
    declare @wtID int
	declare @Calendar int

	select @wtID = ISNULL(A.PERSONALWT,B.ID), @Calendar = ISNULL(B2.CALENDAR,B.CALENDAR)
	from COM_EMPLOYEE A with (nolock) 
	left join COM_WORKTIME B with (nolock) on B.DEPID = A.DEPID and isnull(B.WTDEFAULT,0) = 1
	left join COM_WORKTIME B2 with (nolock) on B2.ID = A.PERSONALWT
	where A.ID = @emplid

	declare @workDayEnd datetime
	select @workDayEnd = max(DEND) from dbo.COM_WORKPERIODS5(@aDateDate,dateadd(day,1,@aDateDate),@Calendar,@wtID,@emplid)
	if @aDate > @workDayEnd /*раб время кончилось*/
	  return 1
  
  end
  

  return 0;
end