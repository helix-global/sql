CREATE PROCEDURE [dbo].[MSG_NAVISION_DEADLOCKS] 
AS
BEGIN

declare @now datetime
set @now = GETDATE()   

if datepart(hour,@now) < 17 return
if datepart(hour,@now) > 17 return
if datepart(minute,@now) < 5 return

set @now = cast(@now as date)
declare @now1 datetime
set @now1 = dateadd(day,1,@now)

if exists (select A.DD 
             from MSG_LAST_DELIVERY_DATES A with (nolock) 
            where A.DELIVERYTYPE = 7777 
              and A.DEPID = 283
              and A.DD = cast(@now as date)
              )
     return

set nocount on
           
declare @ids table (ID int)

insert into @ids (ID)
select A.ID 
from DEF_LOG A with (nolock) 
where A.DD >= @now
  and A.DD < @now1
  and A.LEV in (100,1000)
  and (A.CAPTION like '%Ledger%' or A.CAPTION like '%is locked%')
  and A.EV_TEXT like '%Navision%'

declare @dCou int
declare @mess nvarchar(max)
	
select @dCou = count(*) from @ids

if @dCou > 0
begin
	set @mess = 'Dear All,<br><br>Today the following deadlocks occurred during calling Navision Web services:'
	set @mess = @mess + '<br><br><font size="-2"><table width="1000" cellspacing = "1" bgcolor="#eeeeee" border="1" bordercolor="#ffffff">'
	set @mess = @mess + '<tr><th>Time</th><th>User</th><th>Department</th><th>Message</th></tr>'
	    
	select @mess = @mess + dbo.MSG_LOG_ROWTABLE(A.ID,0)
	from @ids A 
	order by A.ID

	set @mess = @mess + '</table></font><br><b>Total:'+str(@dCou)+'</b><br><br>This e-mail was created automatically.<br>Production Database'

   	/*exec MSG_SEND_TOUSER 0,3,'Daily Deadlocks Report',@mess */
    exec MSG_SEND_TODELIVERYGROUP 0, 7777 ,283,'Daily Deadlocks Report',@mess 
end
else if dbo.COM_IS_WORKDAY(@now,1) = 1
begin

	set @mess = 'Dear All,<br><br>No deadlocks occurred today during calling Navision Web services.'
	set @mess = @mess + '<br><br>This e-mail was created automatically.<br>Production Database'
	exec MSG_SEND_TODELIVERYGROUP 0, 7777 ,283,'Daily Deadlocks Report',@mess 

end

update MSG_NAV_DEADLOCKS set DCOUNT = isnull(@dCou,0) where DD = @now
if @@rowcount = 0
  insert into MSG_NAV_DEADLOCKS (DD,DCOUNT) values (@now,isnull(@dCou,0))

exec MSG_SETLASTDELIVERY_DATE 7777,283,@now
  
set nocount off
END