CREATE procedure [dbo].[COM_ADP_PROCESS_ENTRIES] (
	@dBeg date, @dEnd date, @userId int
)
as
begin

	set xact_abort on
	begin tran

		declare @dBegOrig date = @dBeg

		delete from COM_VACATION_CANCEL

		delete from COM_VACATION
			where cast(DBEG as date)>=@dBeg and cast(DBEG as date)<=@dEnd

		delete from COM_ADDED_WORKTIME
			where cast(DBEG as date)>=@dBeg and cast(DEND as date)<=@dEnd

			
		declare @empId int, @d date, @q int
		
		declare cur_COM_ADP_PROCESS_ENTRIES cursor for
		select O.EMPLOYEEID, O.DBEG, SUM(O.QTY) * 60
			from COM_ADP_TIMEOFF O
			where O.DBEG between @dBeg and @dEnd
		group by O.EMPLOYEEID, O.DBEG

		open cur_COM_ADP_PROCESS_ENTRIES

		fetch next from cur_COM_ADP_PROCESS_ENTRIES into @empId, @d, @q

		while @@fetch_status=0
		begin
		
		--print '---'
		--print @d
		--print @empId
		--print @q
			exec dbo.COM_ADP_ADD_SHABS_TO_WORKDAY @d, @empId, @q, @userId
	
			fetch next from cur_COM_ADP_PROCESS_ENTRIES into @empId, @d, @q
		end

		close cur_COM_ADP_PROCESS_ENTRIES
		deallocate cur_COM_ADP_PROCESS_ENTRIES
		


	commit
end