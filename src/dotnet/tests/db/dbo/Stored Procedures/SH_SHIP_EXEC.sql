CREATE procedure [dbo].[SH_SHIP_EXEC] @DocumentID int, @UserID int 
as
set nocount on

declare @ss int
declare @cou int
declare @dd datetime
declare @now datetime
declare @depID int
declare @depName nvarchar(300)
declare @errmsg nvarchar(max)
declare @blockInProd int
declare @errrr nvarchar(max)
declare @blockAlreadyShipped int
declare @allowShippedDot int
declare @ClearLocationMode int

set @now = getdate()

select @ss = A.S_S
     , @dd = A.DD 
	 , @depID = A.DEPID
	 , @depName = B.NAME
	 , @blockInProd = isnull(C.BLOCK_INPROD,0)
	 , @blockAlreadyShipped = isnull(C.BLOCK_MULTYSH,0)
	 , @allowShippedDot = isnull(C.ALLOW_SHIPPEDDOT,0)
   , @ClearLocationMode = isnull(B.CLEARLOCATIONMODE, 0)
from SH_ORDER A 
left join COM_DEPARTMENTS B on B.ID = A.DEPID
left join SH_SETTINGS C on C.DEPID = A.DEPID
where A.ID = @DocumentID

if cast(@dd as date) = cast(@now as date)
  set @dd = @now

if @ss = 1000024
begin
  
   select @cou = count(*) from SH_ORDER_T where SHORDERID = @DocumentID
    if @cou = 0
    begin
	  set @errmsg = 'Shipment request is empty. Please specify items to ship before proceed.'
      raiserror(@errmsg,15,0)
      set nocount off
	  return
    end
   

   select @cou = count(*) 
     from PR_DEVICE A 
	 left join PR_PRORDER B on B.ID = A.ORDERID
    where A.ID in (select D.DEVICEID from SH_ORDER_T D where D.SHORDERID = @DocumentID)
	  and @depID NOT IN (select ID from [dbo].[COM_GETPARENT_DEPARTMENTS](B.DEPARTMENTID,1)) and B.DEPARTMENTID is not null

    if @cou > 0
    begin
	  set @errmsg = 'Only items produced in the "'+@depName+'" department or in its subordinated departments can be included in this shipment request.'
      raiserror(@errmsg,15,0)
      set nocount off
	  return
    end

	declare @allowedStates table (OID int)
	insert into @allowedStates (OID) values (1000022) /*prod compl*/
	insert into @allowedStates (OID) values (1000039) /*serv compl*/
	insert into @allowedStates (OID) values (1000130) /*imported*/
    if @blockAlreadyShipped <> 1
	begin
	   insert into @allowedStates (OID) values (1000010) /*shipped*/
	end
	if @blockInProd <> 1
	begin
	   insert into @allowedStates (OID) values (1000008) /*in prod*/
	end
	if @allowShippedDot = 1
	begin
	   insert into @allowedStates (OID) values (1000030) /*   shipped*   */
	end
	
	insert into @allowedStates (OID) values (1000077) /*installed - спорно, но иногда попадается оформление с запозданием*/

	select @cou = count(*) 
	  from PR_DEVICE A with (nolock)
	 where A.ID in (select D.DEVICEID from SH_ORDER_T D where D.SHORDERID = @DocumentID)
	   and A.S_S not in (select OID from @allowedStates)

   /*KB1598 -> */
   declare @cou22 int
   select @cou22 = count(*) 
	 from PR_DEVICE A with (nolock)
	 left join PR_MODELS B with (nolock) on B.ID = A.MODELID
	 left join PR_MODELTYPE C with (nolock) on C.ID = B.TYPEID
	where A.ID in (select D.DEVICEID from SH_ORDER_T D where D.SHORDERID = @DocumentID)
	  and A.S_S = 1000077 /*installed*/
	  and C.ACCMODE not in (1,2,4,5)  /* %Qty% */
	  and C.GID <> '8df4c0aa-00c1-4d57-adc1-71674032da02'  /*fiber module*/
   if @cou22 > 0
	 set @cou = 999
   /*KB1598   <- */


   if @cou > 0
   begin
     set @errrr = 'All items in shipment request must be in "Production Completed", "Service Completed" or "Imported" states.'
     raiserror(@errrr,15,0)
     set nocount off
     return
   end

   
	declare @ErrSN nvarchar(50)
    select @ErrSN = B.SN 
	from SH_ORDER_T A 
	left join PR_DEVICE B on B.ID = A.DEVICEID
	where A.SHORDERID = @DocumentID
	  and isnull(B.RESQUANTITY,1) < isnull(A.QTYTOSHIP,1)
   	
	if @ErrSN is not null
	begin
       set @errrr = 'Item "'+@ErrSN+'" quantity is less as specified Qty To Ship.'
       raiserror(@errrr,15,0)
       set nocount off
       return		  
	end

   
	declare @devID int  
	declare cur cursor local read_only for 
	select A.DEVICEID from SH_ORDER_T A where A.SHORDERID = @DocumentID and A.S_S in (1000022,1000039);
	open cur;
	WHILE 1=1
	BEGIN
	   FETCH NEXT FROM cur INTO @devID;
	   IF @@FETCH_STATUS<>0 BREAK;
	   
	   exec PR_CHECK_DEV_SHIPPED @devID,null
	   
	END
	close cur;
	deallocate cur;  

   update SH_ORDER_T set SH_ORDER_T.DEV_PR_SS = (select A.S_S from PR_DEVICE A with (nolock) where A.ID = SH_ORDER_T.DEVICEID)
                        ,S_S = 1000106
                        ,SHIPPINGSTOCK = isnull((select A.SHIPPINGSTOCK from PR_DEVICE A with (nolock) where A.ID = SH_ORDER_T.DEVICEID),SH_ORDER_T.SHIPPINGSTOCK)
   where SH_ORDER_T.SHORDERID = @DocumentID

   if (@ClearLocationMode = 0 /*Shipment Request*/)
   begin
     update PR_DEVICE set SHIPPINGSTOCK = null
     where ID in (select D.DEVICEID from SH_ORDER_T D where D.SHORDERID = @DocumentID)
       and S_S in (1000022,1000039,1000130) /*prod.compl, serv.compl, imported */
   end
   
   update PR_DEVICE set S_S = dbo.SH_NEWSTATE_IF_ALL_SHIPPED(PR_DEVICE.ID,PR_DEVICE.S_S,0) /*1000010  01.02.19 KB438*/
        , SHIPPED_DT = @dd
        --, SHIPPINGSTOCK = null
        , SHIPPED_FIRSTTIME = isnull(SHIPPED_FIRSTTIME,@dd)
        , SHIPPED_FIRSTTIME_DOCID =  isnull(SHIPPED_FIRSTTIME_DOCID,@DocumentID)
    where ID in (select D.DEVICEID from SH_ORDER_T D where D.SHORDERID = @DocumentID)
	  and S_S in (1000022,1000039,1000130) /*prod.compl, serv.compl, imported */
	  
	  
   update PR_DEVICE set SHIPPEDBEFORECMPL_DT = @dd
                      , SHIPPED_FIRSTTIME_DOCID =  isnull(SHIPPED_FIRSTTIME_DOCID,@DocumentID)
    where ID in (select D.DEVICEID from SH_ORDER_T D where D.SHORDERID = @DocumentID)
	  and S_S in (1000008) /*in prod.*/
	
   exec PR_UPDATE_ORDERS null, null, null, @DocumentID

end

if @ss = 1
begin

   select @cou = count(*) 
     from PR_DEVICE A 
    where A.ID in (select D.DEVICEID from SH_ORDER_T D where D.SHORDERID = @DocumentID)
	  and A.S_S not in (1000010,1000008)

   if @cou > 0
   begin
     raiserror('All devices must be in "Shipped" state to cancel this document.',15,0)
     set nocount off
	 return
   end

   update PR_DEVICE set S_S = (select B.DEV_PR_SS from SH_ORDER_T B where B.SHORDERID = @DocumentID and B.DEVICEID = PR_DEVICE.ID)
                       ,SHIPPED_DT = null
					   ,SHIPPEDBEFORECMPL_DT = null
    where ID in (select D.DEVICEID from SH_ORDER_T D where D.SHORDERID = @DocumentID)

   update PR_DEVICE set SHIPPED_FIRSTTIME = null
                       ,SHIPPED_FIRSTTIME_DOCID = null
    where ID in (select D.DEVICEID from SH_ORDER_T D where D.SHORDERID = @DocumentID)
      and SHIPPED_FIRSTTIME_DOCID = @DocumentID


    update SH_ORDER_T set DEV_PR_SS = null
                         ,S_S = 1
    where SH_ORDER_T.SHORDERID = @DocumentID
	
end

exec SH_UPDATE_TRANS @DocumentID, @UserID

set nocount off