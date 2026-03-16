CREATE function [dbo].[SH_COMPONENT_FROM_IPM](@aDeviceIDs nvarchar(max), @shOrderID int)
returns int
as
begin

  declare @devs table (DEVID int not null, IMPEXISTS int)
  
  insert into @devs (DEVID)
  select A.ID
  from PR_DEVICE A with (nolock)
  where A.ID in (select ID from dbo.COM_STR2TABLE_INT(@aDeviceIDs))
  
  if @aDeviceIDs is null and @shOrderID is not null
  begin
		insert into @devs (DEVID)
		select A.DEVICEID
		from SH_ORDER_T A with (nolock)
		where A.SHORDERID = @shOrderID
  end  
  
  /* в изделиях PLA стоит "полусборка" в BOM-Item 1398 (Sub-Module) */
  update @devs set IMPEXISTS = 1
  where exists (select B.PARTID from PR_DEVICE_BOM B with (nolock) 
                where B.DEVICEID = "@devs".DEVID and B.BOMID = 1398 and B.PARTID is not null and B.UNINSTALLOPERID is null)
  
  
  if exists (select DEVID from @devs where IMPEXISTS = 1)
    return 1;
  
  /* в изделиях YLA стоит "полусборка" в BOM-Item 1665 (Sub-...) */
  update @devs set IMPEXISTS = 1
  where exists (select B.PARTID from PR_DEVICE_BOM B with (nolock) 
                 where B.DEVICEID = "@devs".DEVID and B.BOMID = 1665 and B.PARTID is not null and B.UNINSTALLOPERID is null)
  
  if exists (select DEVID from @devs where IMPEXISTS = 1)
    return 1;
    
  /* в изделиях ILA стоит модуль определенных моделей */  
  /*
  6829,6837,7345  RNF, NBF, ZBF 
  ! если номенклатура будет часто менятся, то имеет смысл сделать признак на модели
  
  TODO ? перевести на наличие тэга 'SOP of IPM' ?
  
  */
  update @devs set IMPEXISTS = 1
  where exists (select B.PARTID from PR_DEVICE_BOM B with (nolock) 
                  left join PR_DEVICE C with (nolock) on C.ID = B.PARTID
                 where B.DEVICEID = "@devs".DEVID 
                   and B.UNINSTALLOPERID is null
                   and C.MODELID in (6829,6837,7345)
                )
  if exists (select DEVID from @devs where IMPEXISTS = 1)
    return 1;
  
  
  return 0;
end;