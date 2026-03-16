CREATE function [dbo].[RO_DEVICE_PARAM_IN_LIST_STR](@DeviceID int, @BomTree nvarchar(max), @ParamID int)
returns nvarchar(200) as 
begin
  
  return dbo.PR_DEVICE_PARAM_IN_LIST_STR5(dbo.RO_DEVICE_FROM_TREE(@DeviceID,@BomTree), @ParamID)
  
end