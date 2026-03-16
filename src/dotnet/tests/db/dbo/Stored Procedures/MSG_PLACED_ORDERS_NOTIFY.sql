CREATE PROCEDURE [dbo].[MSG_PLACED_ORDERS_NOTIFY]
AS
BEGIN
/*KB2146

цитата:
Рассылка должна создаваться два раза в день. В 11:00 и 16:00, по заказам в статусе "Placed"

*/

    set nocount on
    
    declare @now datetime = getdate()
    declare @nowDD date = cast(@now as date)
    
    
    if (datepart(hour,@now) < 11) or (datepart(hour,@now) > 17)
    begin
      set nocount off
      return
    end
    
    if dbo.COM_IS_WORKDAY(@now,1) <> 1
    begin
      set nocount off
      return
    end
    
    
    declare @todayDone int
    select @todayDone = A.PART from MSG_LAST_NOTIFICATIONS A with (nolock) where A.DELIVERYTYPE = 2200 and A.DD = @nowDD
    set @todayDone = isnull(@todayDone,0)
    
    if @todayDone = 1 and datepart(hour,@now) < 16
    begin
      set nocount off
      return
    end
    
    if @todayDone = 2
    begin
      set nocount off
      return
    end
    

    declare @placedOrders table (ID int,TODEPID int,FROMDEPID int)
    
    insert into @placedOrders(ID,TODEPID,FROMDEPID)
    select A.ID,A.DEPARTMENTID,B.DEPARTMENTID
    from PR_PRORDER A with (nolock)
    left join PR_PRORDER B with (nolock) on B.ID = A.PARENTORDER
    where A.S_S = 1000063 /*placed*/ 
      and A.DEPARTMENTID in (select distinct G.DEPID from MSG_DELIVERYLIST G with (nolock) where G.DELIVERYTYPE = 2200)  /*order to department*/
      and B.DEPARTMENTID in (select distinct G.DEPID from MSG_DELIVERYLIST G with (nolock) where G.DELIVERYTYPE = 2201)  /*order from department*/
    
        
	declare @toDepid int
	declare @fromDepid int
	
	declare nxx cursor local read_only for 
	select distinct TODEPID,FROMDEPID from @placedOrders
	open nxx 
	WHILE 1=1
	BEGIN
	FETCH NEXT FROM nxx INTO @toDepid,@fromDepid;
	IF @@FETCH_STATUS<>0 BREAK;

        declare @fromCode nvarchar(50), @toCode nvarchar(50)
        
        select @fromCode = A.CODE from COM_DEPARTMENTS A with (nolock) where A.ID = @fromDepid
        
        select @toCode = A.CODE from COM_DEPARTMENTS A with (nolock) where A.ID = @toDepid
        
		declare @mess nvarchar(max)
		set @mess = 'Dear All,<br><br>The following orders are placed from '+@fromCode+' department to '+@toCode+' department:<br><br><font size="-2"><table width="1000" cellspacing = "1" bgcolor="#f5f5f5" border="1" bordercolor="#ffffff">'
		set @mess = @mess + '<tr><th>No</th><th>From Department</th><th>To Department</th><th>Order Date</th><th>Order Reference</th><th>Reference Source Number</th></tr>'
		
		select @mess = @mess + '<tr><td>'+isnull(A.NN,'NA')+'</td><td>'+isnull(D.CODE,'NA')+'</td><td>'+isnull(C.CODE,'NA')+'</td><td>'+isnull(convert(nvarchar,A.DD,104),'NA')+'</td><td>'+isnull(B.NN,'NA')+'</td><td>'+isnull(B.NN2,'NA')+'</td></tr>'
		from PR_PRORDER A with (nolock)
		left join PR_PRORDER B with (nolock) on B.ID = A.PARENTORDER
		left join COM_DEPARTMENTS C with (nolock) on C.ID = A.DEPARTMENTID
		left join COM_DEPARTMENTS D with (nolock) on D.ID = B.DEPARTMENTID
		where A.ID in (select GG.ID from @placedOrders GG where GG.TODEPID = @toDepid and GG.FROMDEPID = @fromDepid)
		order by A.ID desc
		
		set @mess = @mess + '</table></font><br><br>Please, do not answer this e-mail.<br>Production Database'
		
		exec MSG_SEND_TODELIVERYGROUP3 0,2200,@toDepid,2201,@fromDepid,'Placed orders notification',@mess,0 

	END
	close nxx;
	deallocate nxx;    

	if @todayDone = 0
	begin
	   update MSG_LAST_NOTIFICATIONS set PART = 1, DD = @nowDD where DELIVERYTYPE = 2200
	   if @@rowcount = 0
	     insert into MSG_LAST_NOTIFICATIONS (DELIVERYTYPE,PART,DD) values (2200,1,@nowDD)
	end
	if @todayDone = 1  	
	begin
	   update MSG_LAST_NOTIFICATIONS set PART = 2, DD = @nowDD where DELIVERYTYPE = 2200
	   if @@rowcount = 0
	     insert into MSG_LAST_NOTIFICATIONS (DELIVERYTYPE,PART,DD) values (2200,2,@nowDD)
	end
		
	set nocount off	
END