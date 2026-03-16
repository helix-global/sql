create function [dbo].[PR_ALL_OP_DONE3_NEW](@MapID int, @DeviceID int ,@OrderID int, @DoneLevel int, @ParentID int, @TrMapN int)
returns int
begin
  
  if exists (select A.ID from PR_OPERATION A 
              where A.DEVICEID = @DeviceID 
                and A.ORDERID = @OrderID 
                and ISNULL(A.TRMAP_N,0) = ISNULL(@TrMapN,0)
                and isnull(A.PARENTID,0) = ISNULL(@ParentID,0)
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
                   and ISNULL(A.TRMAP_N,0) = ISNULL(@TrMapN,0)
                   and isnull(A.PARENTID,0) = ISNULL(@ParentID,0)
                   and A.S_S in (1000013,1000019)
                )

  update @LastOp set EXISTSOPERATION = 1
  where exists (select A.ID from PR_OPERATION A with (nolock) 
                 where A.DEVICEID = @DeviceID
                   and A.ORDERID = @OrderID
                   and A.REVOPERID = "@LastOp".OPERID
                   and ISNULL(A.TRMAP_N,0) = ISNULL(@TrMapN,0)
                   and isnull(A.PARENTID,0) = ISNULL(@ParentID,0)
                )
  
  update @LastOp set DONE = 1
  where exists (select A.DEVICEID from PR_DEVICE_SKIPPED_OP A with (nolock) 
                 where A.DEVICEID = @DeviceID
                   and A.ORDERID = @OrderID
                   and A.REVOPERID = "@LastOp".OPERID
                   and ISNULL(A.TRMAP_N,0) = ISNULL(@TrMapN,0)
                   and isnull(A.PARENTID,0) = ISNULL(@ParentID,0)                   
                )

  
  /*существует незаконченная обязательная операция - нельзя завершить*/
  if exists (select DONE from @LastOp where DONE = 0 and FLOWNOWAIT = 0)
    return 0

  /*создана незаконченная НЕобязательная операция - нельзя завершить*/
  if exists (select OPERID from @LastOp where DONE = 0 and FLOWNOWAIT <> 0 and EXISTSOPERATION = 1)
    return 0

  /*не существует ни одной НЕзаконченной операции - все готово*/
  if not exists (select OPERID from @LastOp where isnull(DONE,0) <> 1)
    return 1

  /*не существует ни одной предыдущей операции - нельзя завершить*/
  if not exists (select OPERID from @LastOp where EXISTSOPERATION = 1)
    return 0
  
  return 1
end