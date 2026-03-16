CREATE function [dbo].[PR_DEVICE_BOM_TAB] (@DeviceID int)
returns @res table (BOMID int,NEEDMODELID int,NEEDREVID int,PARTID int)
as 
begin
  
  insert into @res (BOMID,NEEDMODELID,NEEDREVID)
  select A.BOMID,A.PARTMODELID,A.PARTONLYREVID
  from dbo.PR_DEVICE_BOM_MODELS(@DeviceID) A
  
  update @res set PARTID = (select top 1 A.PARTID 
                              from dbo.PR_DEVICE_BOM2(@DeviceID) A 
                             where A.BOMID = "@res".BOMID 
                               and A.UNINSTALLOPERID is null
                              order by A.OPERATIONID desc)
  
  return


end