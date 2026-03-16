CREATE FUNCTION [dbo].[CR_FP_FIND_PARENT_PREFORMID](@DeviceID int)
RETURNS int
AS
BEGIN
  
  declare @res int

  declare @modelTypeId int
  declare @preformID int
  declare @drawingID int
  declare @preformSN nvarchar(20)
  declare @sn nvarchar(20)
  
  select  @modelTypeId = B.TYPEID
         ,@sn = A.SN
  from PR_DEVICE A with (nolock) 
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID 
  where A.ID = @DeviceID

  if (@modelTypeId = 295 /*Fiber_Vorform*/)
  begin

    set @res = dbo.PR_GET_DEVICE_ROOT(@DeviceID);
    if (@res is not null and (@res <> @DeviceID) or (select top(1) S_S from PR_DEVICE where ID=@res) <> 1000130 /*Imported*/)
    begin
     return @res;
    end

    set @preformSN = 
      (select splitdata from dbo.COM_STRING_SPLIT(@sn, '-') where idx=0) + '-' + (select splitdata from dbo.COM_STRING_SPLIT(@sn, '-') where idx=1)

    set @preformID =
      (select D.ID 
       from PR_DEVICE D
       left join PR_MODELS M on M.ID=D.MODELID
       where M.TYPEID=295 and (D.SN = @preformSN))
    
    if (@preformID is not null)
    begin
     return @preformID;
    end

    return @res;
  end

  if (@modelTypeId = 126 /*Fibers*/)
  begin
    set @preformID = dbo.PR_DEVICE_BOMITEM(@DeviceID, 2232 /*Fiber_Vorform BOM*/)
    if (@preformID is not null)
    begin
     return dbo.CR_FP_FIND_PARENT_PREFORMID(@preformID);
    end

    set @drawingID = dbo.PR_DEVICE_BOMITEM(@DeviceID, 1409 /*Fiber_Drawing BOM*/)
    if (@drawingID is not null)
    begin
     return dbo.CR_FP_FIND_PARENT_PREFORMID(@drawingID);
    end

    set @preformSN = 
      (select splitdata from dbo.COM_STRING_SPLIT(@sn, '-') where idx=0) + '-' + (select splitdata from dbo.COM_STRING_SPLIT(@sn, '-') where idx=1)

    set @preformID =
      (select D.ID 
       from PR_DEVICE D
       left join PR_MODELS M on M.ID=D.MODELID
       where M.TYPEID=295 and (D.SN = @preformSN))
    
    if (@preformID is not null)
    begin
     return @preformID;
    end

  end

  if (@modelTypeId = 296 /*Fiber_Drawing*/)
  begin
    set @preformID = dbo.PR_DEVICE_BOMITEM(@DeviceID, 1416 /*Fiber_Vorform BOM*/)
    if (@preformID is not null)
    begin
     return dbo.CR_FP_FIND_PARENT_PREFORMID(@preformID);
    end

  end
  
  return @res;

END