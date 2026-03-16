-- KB5351:2025-06-17: Updated [PR_NEXT_OPERATION4] call to pass a parameter in the form "@name = value".
CREATE procedure [dbo].[PR_CHECK_AND_RUN_DELAYED]
  @DeviceID int, @OrdID int
as 
  SET nocount on
  /*запуск по следующему изделию если заказ был запущен в режиме отложенного старта операций*/
  
  declare @ModTypeID int  
  declare @ModelID int 
  declare @OperCrMode int
  declare @IsOperCrModeByModel int
  
  select @ModTypeID = M.TYPEID
       , @ModelID = M.ID
       , @OperCrMode = isnull(M.OPERCRMODE, isnull(T.OPERCRMODE,0)) 
       , @IsOperCrModeByModel = (case when isnull(M.OPERCRMODE,0)>0 then 1 else 0 end)
    from PR_DEVICE D with (nolock)
    left join PR_MODELS M with (nolock) on M.ID = D.MODELID 
    left join PR_MODELTYPE T with (nolock) on T.ID = M.TYPEID
   where D.ID = @DeviceID

  declare @DelayedID int 
  select top 1 @DelayedID = A.ID 
    from PR_DEVICE A with (nolock)
   where A.ORDERID = @OrdID
     and not exists (select B.ID from PR_OPERATION B with (nolock) where B.DEVICEID = A.ID and B.ORDERID = A.ORDERID)
     and A.S_S <> 1000101 /*canceled*/
     and (@IsOperCrModeByModel=1 or A.MODELID not in (select ID from PR_MODELS where TYPEID=@ModTypeID and isnull(OPERCRMODE,0)>0))
     and (@IsOperCrModeByModel<>1 or A.MODELID = @ModelID)
         
  
  if @DelayedID is not null
  begin

    declare nxx cursor local read_only for 
    select A.ID from PR_DEVICE A with (nolock)
     where A.ORDERID = @OrdID
       and not exists (select B.ID from PR_OPERATION B with (nolock) where B.DEVICEID = A.ID and B.ORDERID = A.ORDERID)
       and A.S_S <> 1000101 /*canceled*/
       and (@IsOperCrModeByModel=1 or A.MODELID not in (select ID from PR_MODELS where TYPEID=@ModTypeID and isnull(OPERCRMODE,0)>0))
       and (@IsOperCrModeByModel<>1 or A.MODELID = @ModelID)
     order by A.ID
       
    open nxx 
    WHILE 1=1
    BEGIN
        FETCH NEXT FROM nxx INTO @DelayedID;
        IF @@FETCH_STATUS<>0 BREAK;
        
        exec PR_NEXT_OPERATION4 @DeviceID=@DelayedID,@DoneOperID=null
        
        if not exists (select B.ID from PR_OPERATION B with (nolock) where B.DEVICEID = @DelayedID and B.ORDERID = @OrdID)
          break;

        
    END
    close nxx;
    deallocate nxx;

  end

set nocount off