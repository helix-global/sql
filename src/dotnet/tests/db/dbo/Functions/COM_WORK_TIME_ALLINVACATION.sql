CREATE function [dbo].[COM_WORK_TIME_ALLINVACATION] (@dd date, @emplID int)
returns int
as 
begin
	/* возвращает 1 если все рабочее время в дату @dd закрыто отпусками (в т.ч. короткими отсуствиями) */

	declare @dBeg datetime = cast(@dd as date)
	declare @dEnd datetime = dateadd(day,1,@dBeg)

	declare @calendar int
	declare @whID int
   
	select @whID = ISNULL(A.PERSONALWT,B.ID)
		 , @calendar = ISNULL(B2.CALENDAR,B.CALENDAR)
	from COM_EMPLOYEE A with (nolock) 
	left join COM_WORKTIME B with (nolock) on B.DEPID = A.DEPID and isnull(B.WTDEFAULT,0) = 1
	left join COM_WORKTIME B2 with (nolock) on B2.ID = A.PERSONALWT
	where A.ID = @emplID;

	declare @workPeriods DatePeriodTableType

	insert into @workPeriods (BeginDate,EndDate)
	select DBEG,DEND from dbo.COM_WORKPERIODS5(@dBeg,@dEnd,@calendar,@whID,@emplID)
	if exists(select * from @workPeriods)
	begin

	  declare @vacationPeriods DatePeriodTableType
	  
	  insert into @vacationPeriods (BeginDate,EndDate)
	  select dbo.COM_VACATION_DBEG3(A.ID)
	        ,dbo.COM_VACATION_DEND3(A.ID)
		from COM_VACATION A with (nolock) 
		where A.EMPLID = @emplID 
		and A.S_S in (1000141,2130051)/*appr*/
		and A.DBEG < @dend
		and isnull(A.DEND,A.DBEG) >= @dbeg
		
	  
	   
	  declare @minutes table (DD datetime not null primary key)
	  
	  declare @minDD datetime
	  declare @maxDD datetime

	  select @minDD = min(BeginDate), @maxDD = max(EndDate) from @workPeriods
	    
	  while @minDD <= @maxDD
	  begin
		 insert into @minutes (DD) values (@minDD)
		 set @minDD = dateadd(minute,1,@minDD)
	  end
	  
	  declare @workMinute datetime = null
	  
	  select top 1 @workMinute = DD
	  from @minutes
	  where exists (select * from @workPeriods where BeginDate <= "@minutes".DD and EndDate > "@minutes".DD)
		and not exists (select * from @vacationPeriods where BeginDate <= "@minutes".DD and EndDate > "@minutes".DD)
	    
	  if @workMinute is null
	    return 1
	
		
	end   


	return 0
end