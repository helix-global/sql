create function [dbo].[WEB_GET_EQ_MODELS_4_PARAM](@OperID int, @paramID int)
returns @eqmodels table (ID int )
as 
begin
  
  /*KB3346
  выдает модели оборудования, которые подходят для @ParamID на операции @OperID
  */

declare @MtID int
declare @DeviceID int

select @MtID = C.TYPEID
      ,@DeviceID = A.DEVICEID
from PR_OPERATION A with(nolock)
left join PR_DEVICE B with(nolock) on B.ID = A.DEVICEID
left join PR_MODELS C with(nolock) on C.ID = B.MODELID
where A.ID = @OperID

declare @opts table (OPTID int not null)
 
insert into @opts (OPTID) 
select B.OPTID from PR_DEVICE_OPT B with (nolock) where B.DEVICEID = @DeviceID

/*сначала д.б. с ревизий */


/*затем с типа моделей*/
insert into @eqmodels (ID) 
select B.ID
from PR_MODELTYPE_COMMON_EQ A with (nolock)
left join PR_MODELTYPE_COMMON AA with (nolock) on AA.ID = A.MTID
left join EQ_MODELS B on B.EQTYPEID = A.EQTYPEID and (B.ID = A.EQMODELID or A.EQMODELID is null)
where AA.MTID = @MtID
  and A.EQID = @paramID
  and A.ONLYOPTION in (select OPTID from @opts)
  and A.ONLYOPTION2 in (select OPTID from @opts)
  and A.ONLYOPTION3 in (select OPTID from @opts)
  and not exists (select * from @eqmodels VV where VV.ID = B.ID)

insert into @eqmodels (ID) 
select B.ID
from PR_MODELTYPE_COMMON_EQ A with (nolock)
left join PR_MODELTYPE_COMMON AA with (nolock) on AA.ID = A.MTID
left join EQ_MODELS B on B.EQTYPEID = A.EQTYPEID and (B.ID = A.EQMODELID or A.EQMODELID is null)
where AA.MTID = @MtID
  and A.EQID = @paramID
  and A.ONLYOPTION in (select OPTID from @opts)
  and A.ONLYOPTION2 in (select OPTID from @opts)
  and A.ONLYOPTION3 is null 
  and not exists (select * from @eqmodels VV where VV.ID = B.ID)

insert into @eqmodels (ID) 
select B.ID
from PR_MODELTYPE_COMMON_EQ A with (nolock)
left join PR_MODELTYPE_COMMON AA with (nolock) on AA.ID = A.MTID
left join EQ_MODELS B on B.EQTYPEID = A.EQTYPEID and (B.ID = A.EQMODELID or A.EQMODELID is null)
where AA.MTID = @MtID
  and A.EQID = @paramID
  and A.ONLYOPTION in (select OPTID from @opts)
  and A.ONLYOPTION2 is null
  and A.ONLYOPTION3 is null 
  and not exists (select * from @eqmodels VV where VV.ID = B.ID)

  
insert into @eqmodels (ID) 
select B.ID
from PR_MODELTYPE_COMMON_EQ A with (nolock)
left join PR_MODELTYPE_COMMON AA with (nolock) on AA.ID = A.MTID
left join EQ_MODELS B on B.EQTYPEID = A.EQTYPEID and (B.ID = A.EQMODELID or A.EQMODELID is null)
where AA.MTID = @MtID
  and A.EQID = @paramID
  and A.ONLYOPTION is null
  and A.ONLYOPTION2 is null
  and A.ONLYOPTION3 is null 
  and not exists (select * from @eqmodels VV where VV.ID = B.ID)
  
  
  return

end