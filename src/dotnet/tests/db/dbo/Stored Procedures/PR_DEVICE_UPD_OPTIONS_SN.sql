CREATE procedure [dbo].[PR_DEVICE_UPD_OPTIONS_SN]
 @DeviceID int
as 
SET nocount on

declare @opts table (ID int, OPTID int, OPTSN nvarchar(50), BOMID int, OPTSN_NEW nvarchar(50), NEEDUPDATE int) 

insert into @opts (ID,OPTID,OPTSN,BOMID)
select A.ID,A.OPTID,A.OPTSN,isnull(A.BOMID,B.SNBOMID)
from PR_DEVICE_OPT A
left join PR_MODELTYPE_OPTIONS B on B.ID = A.OPTID
where A.DEVICEID = @DeviceID
  and ISNULL(B.SNTRACKING,0) = 1

update @opts set OPTSN_NEW = ltrim(rtrim(dbo.PR_DEVICE_BOMITEM_SN(@DeviceID,BOMID,0)))
update @opts set NEEDUPDATE = 1 where OPTSN_NEW is not null and OPTSN_NEW <> ISNULL(OPTSN,'s f g')

update PR_DEVICE_OPT set OPTSN = (select A.OPTSN_NEW from @opts A where A.ID = PR_DEVICE_OPT.ID)
where PR_DEVICE_OPT.ID in (select B.ID from @opts B where B.NEEDUPDATE = 1)
  and PR_DEVICE_OPT.DEVICEID = @DeviceID

SET nocount off