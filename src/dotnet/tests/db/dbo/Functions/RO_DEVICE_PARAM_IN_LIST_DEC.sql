CREATE function [dbo].[RO_DEVICE_PARAM_IN_LIST_DEC](@DeviceID int, @BomTree nvarchar(max), @ParamID int)
returns decimal as 
begin
  
  return dbo.PR_DEVICE_PARAM_IN_LIST_DEC(dbo.RO_DEVICE_FROM_TREE(@DeviceID,@BomTree), @ParamID)
  
end