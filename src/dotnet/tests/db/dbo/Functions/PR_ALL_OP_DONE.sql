CREATE function [dbo].[PR_ALL_OP_DONE](@MapID int, @DeviceID int ,@OrderID int, @DoneLevel int)
returns int
begin
  
  if exists (select A.ID from PR_OPERATION A 
              where A.DEVICEID = @DeviceID 
                and A.ORDERID = @OrderID 
                and A.S_S in (1000031/*in progr*/,1000032/*pending*/,1000033/*postponed*/))
                return 0 
              
  
  declare @LastOp table (OPERID int not null, DONE int not null, FLOWNOWAIT int, EXISTSOPERATION int)
  
  insert into @LastOp (OPERID,DONE,FLOWNOWAIT)
  select A.OP_FROM,0,isnull(FLOWNOWAIT,0) from PR_MAP_FLOW A with (nolock) where A.MAPID = @MapID and A.OP_TO is null 
  
  update @LastOp set DONE = 1
  where exists (select A.ID from PR_OPERATION A with (nolock) 
                 where A.DEVICEID = @DeviceID
                   and A.ORDERID = @OrderID
                   and A.REVOPERID = "@LastOp".OPERID
                   and A.S_S in (1000013,1000019)
                )

  update @LastOp set EXISTSOPERATION = 1
  where exists (select A.ID from PR_OPERATION A with (nolock) 
                 where A.DEVICEID = @DeviceID
                   and A.ORDERID = @OrderID
                   and A.REVOPERID = "@LastOp".OPERID
                )
  
  update @LastOp set DONE = 1
  where exists (select A.DEVICEID from PR_DEVICE_SKIPPED_OP A with (nolock) 
                 where A.DEVICEID = @DeviceID
                   and A.ORDERID = @OrderID
                   and A.REVOPERID = "@LastOp".OPERID
                )

  
  /*существует незаконченная обязательная операция*/
  if exists (select DONE from @LastOp where DONE = 0 and FLOWNOWAIT = 0)
    return 0

  /*создана незаконченная НЕобязательная операция - нельзя завершить*/
  if exists (select OPERID from @LastOp where DONE = 0 and FLOWNOWAIT <> 0 and EXISTSOPERATION = 1)
    return 0

  
  return 1
end