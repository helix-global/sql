create function [dbo].[RO_DEVICE_PARAM_IN_LIST_DATETIME](@DeviceID int, @BomTree nvarchar(max), @ParamID int)
returns datetime as 
begin
  
  return dbo.PR_DEVICE_PARAM_IN_LIST_DATETIME(dbo.RO_DEVICE_FROM_TREE(@DeviceID,@BomTree), @ParamID)
  
end