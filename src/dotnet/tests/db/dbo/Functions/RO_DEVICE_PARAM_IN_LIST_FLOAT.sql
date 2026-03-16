create function [dbo].[RO_DEVICE_PARAM_IN_LIST_FLOAT](@DeviceID int, @BomTree nvarchar(max), @ParamID int)
returns float as 
begin
  
  return dbo.PR_DEVICE_PARAM_IN_LIST_FLOAT(dbo.RO_DEVICE_FROM_TREE(@DeviceID,@BomTree), @ParamID)
  
end