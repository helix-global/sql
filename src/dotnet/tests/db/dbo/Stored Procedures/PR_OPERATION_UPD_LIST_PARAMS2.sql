create procedure [dbo].[PR_OPERATION_UPD_LIST_PARAMS2] @aDeviceID int, @aMTid int
as 
SET nocount on

declare @mtid int = @aMTid

if @aMTid is null
begin
	select @mtid = B.TYPEID
	from PR_DEVICE C with (nolock)
	left join PR_MODELS B with (nolock) on B.ID = C.MODELID
	where C.ID = @aDeviceID
end

declare @need table (PARAMID int not null,PVALUE sql_variant,SAMEVALUES int)

insert into @need (PARAMID,PVALUE,SAMEVALUES)
select M.PARAMID,M.PVALUE,case when M.PVALUE = B.PVALUE then 1 when M.PVALUE is null and B.PVALUE is null then 1 else 0 end
from(
	select A.ID as PARAMID,dbo.PR_DEVICE_PARAM(@aDeviceID,A.ID) as PVALUE
	from PR_MODELTYPE_PARAMS_INLIST A with(nolock,noexpand) where A.TYPEID = @mtid
) M 
left join PR_LIST_PARAMS_CACHE B with (nolock) on B.DEVICEID = @aDeviceID and B.PARAMID = M.PARAMID

delete from PR_LIST_PARAMS_CACHE 
where DEVICEID = @aDeviceID
  and PARAMID not in (select PARAMID from @need)

update PR_LIST_PARAMS_CACHE set PR_LIST_PARAMS_CACHE.PVALUE = (select B.PVALUE from @need B where B.PARAMID = PR_LIST_PARAMS_CACHE.PARAMID)
where PR_LIST_PARAMS_CACHE.DEVICEID = @aDeviceID
  and PR_LIST_PARAMS_CACHE.PARAMID in (select PARAMID from @need where SAMEVALUES = 0)
  
insert into PR_LIST_PARAMS_CACHE (DEVICEID,PARAMID,PVALUE)
select @aDeviceID,A.PARAMID,A.PVALUE
from @need A 
where A.PARAMID not in (select B.PARAMID from PR_LIST_PARAMS_CACHE B where B.DEVICEID = @aDeviceID)

SET nocount off