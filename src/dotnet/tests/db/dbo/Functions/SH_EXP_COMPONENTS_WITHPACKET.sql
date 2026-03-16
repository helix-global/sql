CREATE function [dbo].[SH_EXP_COMPONENTS_WITHPACKET] (@aShReqID int, @aUserID int, @aMode int)
returns @res table (ID int,MTMODE int,BLEVEL int,ROOTMTID int)
as 
begin

/*
KB2185 добавлен 2-ой уровень вложенности компонент

если дело дойдет до 3го и т.д. уровней то можно сделать 
настройку в SH_OUTXMLSETTINGS до какого уровня подбирать
компоненты и тут делать подборы в циклах 
*/

insert into @res (ID,MTMODE,BLEVEL,ROOTMTID)
select distinct D.PARTID,isnull(STT.MTMODE,0),1,C.TYPEID
from SH_ORDER_T A with (nolock)
left join PR_DEVICE B with (nolock) on B.ID = A.DEVICEID
left join PR_MODELS C with (nolock) on C.ID = B.MODELID
left join PR_DEVICE_BOM D with (nolock) on D.DEVICEID = A.DEVICEID
left join PR_MODELS DM with (nolock) on DM.ID = D.MODELID
left join SH_OUTXMLSETTINGS ST with (nolock) on ST.MTID = C.TYPEID
left join SH_OUTXMLSETTINGS_T STT with (nolock) on STT.VNESHID = ST.ID and STT.MTID = DM.TYPEID
where A.SHORDERID = @aShReqID
  and D.UNINSTALLOPERID is null
  and isnull(ST.CPARAMS,0) = 1
  and STT.ID is not null


/*LEVEL 2*/

insert into @res(ID,MTMODE,BLEVEL,ROOTMTID)
select distinct D.PARTID,isnull(STT.MTMODE,0),2,A.ROOTMTID
from @res A 
left join PR_DEVICE_BOM D with (nolock) on D.DEVICEID = A.ID
left join PR_MODELS DM with (nolock) on DM.ID = D.MODELID
left join SH_OUTXMLSETTINGS ST with (nolock) on ST.MTID = A.ROOTMTID
left join SH_OUTXMLSETTINGS_T STT with (nolock) on STT.VNESHID = ST.ID and STT.MTID = DM.TYPEID
where D.UNINSTALLOPERID is null
  and isnull(ST.CPARAMS,0) = 1
  and STT.ID is not null


return

end