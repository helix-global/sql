
CREATE PROC [dbo].[PR_OPERATION_TERMS_NOTIFY]
AS

--Добавление сообщений о невыполненных операциях за укаанное кол-во дней до Planned Date производственного заказа

declare @tResult table  (msgto nvarchar(1024), subj nvarchar(1024), body ntext)

declare @empID int, @oldempID int
declare @msgto nvarchar(1024), @subj nvarchar(1024)
set @oldempID =0 
set @empID = 0
set @subj = 'Operations Not Completed'

declare @operName nvarchar(100), @mtName nvarchar(300), @nn nvarchar(20), @sn nvarchar(50), @mName nvarchar(200), @email nvarchar(200), @oldemail nvarchar(200)
declare @s varchar(4000), @plannedDate datetime, @mapOperID int

declare @tOpers table (ID int, SN nvarchar(50), NN nvarchar(20), operName nvarchar(100), 
		mtName nvarchar(300), mName nvarchar(200), email nvarchar(200), PlannedDate datetime, mapOperID int, orderID int)

insert into @tOpers(ID, NN, SN, operName, mtName, mName, email, PlannedDate, mapOperID, orderID)
select e.ID, o.NN, d.SN, ops.NAME, mt.NAME, m.NAME, e.EMAIL, o.EXPDATE, mapo.ID, o.ID
	from PR_DEVICE d with (nolock)
		join PR_PRORDER o with (nolock) on d.ORDERID=o.ID
		join PR_MODELS m with (nolock) on d.MODELID=m.ID
		join PR_REVISION r with (nolock) on d.REVID=r.ID 
		join PR_MAP map with (nolock) on r.MAPID=map.ID
		join PR_MAP_OPER mapo with (nolock) on map.ID=mapo.MAPID
		join PR_OPERATION_TERMS_SUBSCRIPTION s with (nolock) on m.TYPEID=s.MODELTYPEID AND mapo.OPERID = s.OPERATIONID
		join PR_OPERATIONS ops with (nolock) on mapo.OPERID=ops.ID
		join PR_MODELTYPE mt with (nolock) on m.TYPEID=mt.ID
		join PR_OPERATION_TERMS_SUBSCRIPTION_T st with (nolock) ON s.ID=st.VNESHID
		JOIN COM_EMPLOYEE e with (nolock) on st.EMPLOYEEID=e.ID
where m.TYPEID in (select gm.MODELTYPEID from PR_OPERATION_TERMS_SUBSCRIPTION gm with (nolock))
  and CAST(DATEADD(day,s.[DAYS],GETDATE()) as DATE) = CAST(o.EXPDATE as DATE)
  and s.MODELID is null 
  and o.ID not in(select n.PRORDERID from PR_OPERATION_TERMS_NOTIFICATIONS n)
  and e.EMAIL is not null
order by e.ID, d.ID

insert into @tOpers(ID, NN, SN, operName, mtName, mName, email, PlannedDate, mapOperID, orderID)
select e.ID, o.NN, d.SN, ops.NAME, mt.NAME, m.NAME, e.EMAIL, o.EXPDATE, mapo.ID, o.ID
	from PR_DEVICE d with (nolock)
		join PR_PRORDER o with (nolock) on d.ORDERID=o.ID
		join PR_MODELS m with (nolock) on d.MODELID=m.ID
		join PR_REVISION r with (nolock) on d.REVID=r.ID 
		join PR_MAP map with (nolock) on r.MAPID=map.ID
		join PR_MAP_OPER mapo with (nolock) on map.ID=mapo.MAPID
		join PR_OPERATION_TERMS_SUBSCRIPTION s with (nolock) on d.MODELID=s.MODELID AND mapo.OPERID = s.OPERATIONID
		join PR_OPERATIONS ops with (nolock) on mapo.OPERID=ops.ID
		join PR_MODELTYPE mt with (nolock) on m.TYPEID=mt.ID
		join PR_OPERATION_TERMS_SUBSCRIPTION_T st with (nolock) ON s.ID=st.VNESHID
		JOIN COM_EMPLOYEE e with (nolock) on st.EMPLOYEEID=e.ID
where m.TYPEID in (select gm.MODELTYPEID from PR_OPERATION_TERMS_SUBSCRIPTION gm with (nolock))
  and d.MODELID in (select gg.MODELID from PR_OPERATION_TERMS_SUBSCRIPTION gg with (nolock))
  and s.MODELID is not null
  and CAST(DATEADD(day,s.[DAYS],GETDATE()) as DATE) = CAST(o.EXPDATE as DATE) 
  and o.ID not in(select n.PRORDERID from PR_OPERATION_TERMS_NOTIFICATIONS n)
  and e.EMAIL is not null
order by e.ID, d.ID

declare @tCompleted table (mapOperID int, orderID int)
insert into @tCompleted (mapOperID, orderID)
select op.mapOperID, op.orderID
from PR_OPERATION o with (nolock)
	join @tOpers op on o.ORDERID=op.orderID  AND o.REVOPERID=op.mapOperID
	where S_S=1000021

delete from @tOpers
from @tOpers o join @tCompleted c on o.mapOperID=c.mapOperID and o.orderID=c.orderID


declare cur_OperTermsSubscr_Sub cursor for 
select o.ID, o.NN, o.SN, o.operName, o.mtName, o.mName, o.email, o.PlannedDate
from @tOpers o

open cur_OperTermsSubscr_Sub

fetch next from cur_OperTermsSubscr_Sub into @empID, @nn, @sn, @operName, @mtName, @mName, @email, @plannedDate

while @@FETCH_STATUS=0
begin
	if @empID<>@oldempID 
	begin
		
		if @oldempID<>0
		begin
			
			set @s = 'Dear All,<br><br> there are operations that have not been completed.<br><br><font size="-2"><table width="1000" cellspacing = "1" bgcolor="#eeeeee" border="1" bordercolor="#ffffff"><thead><th>Production Order Number</th><th>Item SN</th><th>Operation</th><th>Model Type</th><th>Model</th><th>Planned Date</th></thead>' + @s + '</table></font>'

			insert into @tResult (msgto, subj, body)
			values(@oldemail, @subj, @s)

		end

		set @oldempID=@empID
		set @oldemail = @email

		set @s = ''
	end 
		
	set @s=@s + '<tr><td>' + @nn + '</td><td>' + @sn + '</td><td>' + @operName + '</td><td>' + @mtName + '</td><td>' + @mName + '</td><td>' + CAST(@plannedDate as nvarchar(20)) + '</td></tr>'
		
	fetch next from cur_OperTermsSubscr_Sub into  @empID, @nn, @sn, @operName, @mtName, @mName, @email, @plannedDate
end
 

set @s = 'Dear All,<br><br> there are operations that have not been completed.<br><br><font size="-2"><table width="1000" cellspacing = "1" bgcolor="#eeeeee" border="1" bordercolor="#ffffff"><thead><th>Production Order Number</th><th>Item SN</th><th>Operation</th><th>Model Type</th><th>Model</th><th>Planned Date</th></thead>' + @s + '</table></font>'

insert into @tResult (msgto, subj, body)
values(@oldemail, @subj, @s)

close cur_OperTermsSubscr_Sub

deallocate cur_OperTermsSubscr_Sub

insert into MSG_OUTGOING ( S_S, GID, [MSGTO], [MSGSUBJ], [MSGBODY], S_CR, S_CDT)
select 1, NEWID(), msgto, subj, body, 0, getdate()
from @tResult r
where r.msgto is not null
  and r.subj is not null
  

insert into PR_OPERATION_TERMS_NOTIFICATIONS ( PRORDERID, DD)
select orderID, getdate()
from (
select distinct t.orderID
from @tOpers t
) M