CREATE function [dbo].[RO_DEVICE_PARAM_IN_LIST_INT](@DeviceID int, @BomTree nvarchar(max), @ParamID int)
returns int as 
begin
  
  return dbo.PR_DEVICE_PARAM_IN_LIST_INT(dbo.RO_DEVICE_FROM_TREE(@DeviceID,@BomTree), @ParamID)
  
end