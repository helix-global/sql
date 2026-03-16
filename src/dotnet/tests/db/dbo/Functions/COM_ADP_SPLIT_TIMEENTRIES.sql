create FUNCTION [dbo].[COM_ADP_SPLIT_TIMEENTRIES]
(
	@dBeg datetime, @dEnd datetime
)
RETURNS @ret TABLE 
(
	EMPLOYEEID int
	, DBEG datetime
	, DEND datetime
	, MINUTES int
)
AS
BEGIN
	declare @empId int, @db datetime, @de datetime


	declare cur_COM_ADP_SPLIT_TIMEENTRIES cursor for
	select T.EMPLOYEEID
			, T.DBEG
			, T.DEND			
		from COM_ADP_TIMEENTRIES T
			where T.DEND>=cast(@dBeg as date) and T.DBEG<=cast(@dEnd as date)
				and T.EMPLOYEEID is not null
		order by T.EMPLOYEEID, T.DBEG, T.DEND	


					
	open cur_COM_ADP_SPLIT_TIMEENTRIES

	fetch next from cur_COM_ADP_SPLIT_TIMEENTRIES into @empId, @db, @de

	while @@fetch_status=0
	begin
		
		if cast(@db as date)=cast(@de as date)
			insert into @ret (EMPLOYEEID, DBEG, DEND, MINUTES)
				values(@empId, @db, @de, datediff(minute,@db,@de))
		else
		begin
			insert into @ret (EMPLOYEEID, DBEG, DEND, MINUTES)
				values(@empId, @db, cast(@de as date), datediff(minute,@db,cast(@de as date)))
			insert into @ret (EMPLOYEEID, DBEG, DEND, MINUTES)
				values(@empId, cast(@de as date), @de, datediff(minute,cast(@de as date),@de))
		end
	
		 fetch next from cur_COM_ADP_SPLIT_TIMEENTRIES into @empId, @db, @de
	end

	close cur_COM_ADP_SPLIT_TIMEENTRIES
	deallocate cur_COM_ADP_SPLIT_TIMEENTRIES
	
	RETURN 
END