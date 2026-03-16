CREATE function [dbo].[SH_COMPONENT_FROM_IPM_SNS](@shOrderID int)
returns nvarchar(max)
as
begin

  declare @devs table (DEVID int not null, IMPEXISTS int)
  
  insert into @devs (DEVID)
  select A.DEVICEID
  from SH_ORDER_T A with (nolock)
  where A.SHORDERID = @shOrderID
  
  
  /* в изделиях PLA стоит "полусборка" в BOM-Item 1398 (Sub-Module) */
  update @devs set IMPEXISTS = 1
  where exists (select B.PARTID from PR_DEVICE_BOM B with (nolock) 
                where B.DEVICEID = "@devs".DEVID and B.BOMID = 1398 and B.PARTID is not null and B.UNINSTALLOPERID is null)
  
  
  
  /* в изделиях YLA стоит "полусборка" в BOM-Item 1665 (Sub-...) */
  update @devs set IMPEXISTS = 1
  where exists (select B.PARTID from PR_DEVICE_BOM B with (nolock) 
                 where B.DEVICEID = "@devs".DEVID and B.BOMID = 1665 and B.PARTID is not null and B.UNINSTALLOPERID is null)
  
    
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
  
  
  declare @res nvarchar(max) 
  
  select @res = isnull(@res,'') + B.SN + ','
  from PR_DEVICE B with (nolock)
  where B.ID in (select DEVID from @devs where IMPEXISTS = 1)
  
  if LEN(@res) > 2
    set @res = substring(@res,0,len(@res))

  
  return @res
end;