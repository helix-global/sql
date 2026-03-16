CREATE procedure [dbo].[PR_UPDATE_ORDERS] @aDeviceID int, @aProdOrderID int, @aSupplyOrderID int, @aShipReqID int
as 
set nocount on

if @aDeviceID is not null
begin
  update PR_SUPPLY set S_S = dbo.PR_SO_NEED_STATE(PR_SUPPLY.ID) 
   where PR_SUPPLY.ID = (select A.SORDERID from PR_DEVICE A with (nolock) where A.ID = @aDeviceID)
     and PR_SUPPLY.S_S <> dbo.PR_SO_NEED_STATE(PR_SUPPLY.ID)
     and dbo.PR_SO_LOCKED_IN_SHIPPED(PR_SUPPLY.ID,PR_SUPPLY.DEPARTMENTID,PR_SUPPLY.S_S) <> 1
     
  declare @nowState int
  select @nowState = A.S_S
  from PR_DEVICE A with (nolock)
  where A.ID = @aDeviceID
  
  if @nowState = 1000039 /*repair cmpl.*/
  begin
     update PR_PRORDER set S_S = 1000036 /*cmpl*/
     where PR_PRORDER.ID in (select B.ORDERID from PR_PRORDER_SERVICE B with (nolock) where B.DEVICEID = @aDeviceID)
       and PR_PRORDER.S_S = 1000035 /*in progress*/
       and not exists (select D.ID
                         from PR_PRORDER_SERVICE C with (nolock)
                         left join PR_DEVICE D with (nolock) on D.ID = C.DEVICEID
                        where C.ORDERID = PR_PRORDER.ID
                          and D.S_S in (1000011/*in serv*/,1000100/*postponed srv*/)
                          )
  end
     
end  

if @aProdOrderID is not null
begin
  update PR_SUPPLY set S_S = dbo.PR_SO_NEED_STATE(PR_SUPPLY.ID) 
   where PR_SUPPLY.ID = (select A.SORDERID from PR_DEVICE A with (nolock) where A.ORDERID = @aProdOrderID)
     and PR_SUPPLY.S_S <> dbo.PR_SO_NEED_STATE(PR_SUPPLY.ID)
     and dbo.PR_SO_LOCKED_IN_SHIPPED(PR_SUPPLY.ID,PR_SUPPLY.DEPARTMENTID,PR_SUPPLY.S_S) <> 1
end

if @aSupplyOrderID is not null
begin
  update PR_SUPPLY set S_S = dbo.PR_SO_NEED_STATE(PR_SUPPLY.ID) 
   where PR_SUPPLY.ID = @aSupplyOrderID
     and PR_SUPPLY.S_S <> dbo.PR_SO_NEED_STATE(PR_SUPPLY.ID)
     and dbo.PR_SO_LOCKED_IN_SHIPPED(PR_SUPPLY.ID,PR_SUPPLY.DEPARTMENTID,PR_SUPPLY.S_S) <> 1
end

if @aShipReqID is not null
begin
  update PR_SUPPLY set S_S = dbo.PR_SO_NEED_STATE(PR_SUPPLY.ID) 
   where PR_SUPPLY.ID in (select A.SORDERID from PR_DEVICE A with (nolock) where A.ID in (select B.DEVICEID from SH_ORDER_T B with (nolock) where B.SHORDERID = @aShipReqID))
     and PR_SUPPLY.S_S <> dbo.PR_SO_NEED_STATE(PR_SUPPLY.ID)
     and dbo.PR_SO_LOCKED_IN_SHIPPED(PR_SUPPLY.ID,PR_SUPPLY.DEPARTMENTID,PR_SUPPLY.S_S) <> 1
end


set nocount off