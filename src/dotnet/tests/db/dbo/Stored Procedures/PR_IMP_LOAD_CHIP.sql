CREATE procedure [dbo].[PR_IMP_LOAD_CHIP]  @MTID int, @UserID int
as 
set nocount on

update ##temp_import_chip set MODELID = (select B.ID from PR_MODELS B where B.TYPEID = @MTID and B.CODE = ##temp_import_chip.PN collate database_default)

update ##temp_import_chip set MODELID = (select top 1 B.ID from PR_MODELS B where B.TYPEID = @MTID and B.NAME = ##temp_import_chip.PN collate database_default)
 where MODELID is null
 
update ##temp_import_chip set DEVICEID = (select B.ID from PR_DEVICE B where B.MODELID = ##temp_import_chip.MODELID and B.SN = ##temp_import_chip.SN collate database_default)

delete from ##temp_import_chip_p where VNESHID in (select ID from ##temp_import_chip where DEVICEID is not null)
delete from ##temp_import_chip where DEVICEID is not null

insert into PR_DEVICE (GID,S_CR,S_CDT,S_S,MODELID,SN)
select newid(),@UserID,getdate(),1000030,MODELID,SN
from ##temp_import_chip A 
where A.DEVICEID is null

update ##temp_import_chip set DEVICEID = (select B.ID from PR_DEVICE B where B.MODELID = ##temp_import_chip.MODELID and B.SN = ##temp_import_chip.SN collate database_default)

insert into PR_DEVICE_IN_VALUES (DEVICEID,PARAMID,PVALUE)
select B.DEVICEID,A.PARAMID,A.PVALUE
from ##temp_import_chip_p A
left join ##temp_import_chip B on B.ID = A.VNESHID


set nocount off