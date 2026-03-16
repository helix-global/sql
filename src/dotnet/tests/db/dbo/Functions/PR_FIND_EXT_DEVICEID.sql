create function [dbo].PR_FIND_EXT_DEVICEID(@OperID int, @BomID int, @BomID2 int, @BomID3 int)
returns int as 
begin
  
  declare @res int
  
  select @res = A.DEVICEID
  from PR_OPERATION A with (nolock)
  where A.ID = @OperID
  
  if @BomID > 0 and @res > 0
  begin
    set @res = dbo.PR_DEVICE_BOMITEM(@res,@BomID)
  end

  if @BomID2 > 0 and @res > 0
  begin
    set @res = dbo.PR_DEVICE_BOMITEM(@res,@BomID2)
  end

  if @BomID3 > 0 and @res > 0
  begin
    set @res = dbo.PR_DEVICE_BOMITEM(@res,@BomID3)
  end
   
  
  return @res;  

end