CREATE PROCEDURE [dbo].[COM_ADP_ADD_SHABS_TO_WORKDAY]
	@date datetime, @empId int, @minutes int, @userId int
AS
BEGIN
	
	declare @t table (DBEG datetime, DEND datetime, MINUTES int)

	declare @dOrig datetime

	set @dOrig = cast(cast(@date as date) as datetime)

	insert into @t
	values( dateadd(minute, 480, @dOrig ), dateadd(minute, 720, @dOrig), 240)

	insert into @t
	values( dateadd(minute, 780, @dOrig), dateadd(minute, 1020, @dOrig), 240)

	--insert into @t (DBEG, DEND, MINUTES)
	--select T.DBEG, T.DEND, DATEDIFF(MINUTE, T.DBEG, T.DEND)
	--	from dbo.COM_WORKPERIODS(@date,@date, 1, 51, @empId) T


	declare @dBeg datetime, @dEnd datetime, @m int, @m_tmp int

	declare cur_COM_ADP_ADD_SHABS_TO_WORKDAY cursor for
	select DBEG, DEND, MINUTES
		from @t
		order by DBEG
					
	open cur_COM_ADP_ADD_SHABS_TO_WORKDAY

	fetch next from cur_COM_ADP_ADD_SHABS_TO_WORKDAY into @dBeg, @dEnd, @m

	if @minutes<=@m	
		insert into COM_VACATION ( GID, S_CR, S_CDT, EMPLID, VACATIONTYPE, DBEG, SHORTSTART, SHORTDURATION, S_S)
				select newid(), @userId, getdate(), @empId, 30, @dBeg, @dBeg, @minutes, 1000141
	else
	begin
		insert into COM_VACATION ( GID, S_CR, S_CDT, EMPLID, VACATIONTYPE, DBEG, SHORTSTART, SHORTDURATION, S_S)
				select newid(), @userId, getdate(), @empId, 30, @dBeg, @dBeg, @m, 1000141

		set @m_tmp = @minutes - @m

		fetch next from cur_COM_ADP_ADD_SHABS_TO_WORKDAY into @dBeg, @dEnd, @m
		
		while @@fetch_status=0 and @m_tmp>0
		begin
		
			if @m_tmp<=@m
			begin
				insert into COM_VACATION ( GID, S_CR, S_CDT, EMPLID, VACATIONTYPE, DBEG, SHORTSTART, SHORTDURATION, S_S)
						select newid(), @userId, getdate(), @empId, 30, @dBeg, @dBeg, @m_tmp, 1000141 
				set @m_tmp=0
			end
			else
			begin
				insert into COM_VACATION ( GID, S_CR, S_CDT, EMPLID, VACATIONTYPE, DBEG, SHORTSTART, SHORTDURATION, S_S)
						select newid(), @userId, getdate(), @empId, 30, @dBeg, @dBeg, @m, 1000141
				set @m_tmp = @m_tmp - @m
			end
	
			 fetch next from cur_COM_ADP_ADD_SHABS_TO_WORKDAY into @dBeg, @dEnd, @m
		end

	end
	
	close cur_COM_ADP_ADD_SHABS_TO_WORKDAY
	deallocate cur_COM_ADP_ADD_SHABS_TO_WORKDAY
END