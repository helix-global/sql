CREATE procedure [dbo].[PR_IMP_LOAD_CHIP2]  @ImpTypeID int, @UserID int
as 
set nocount on

declare @MTID int
declare @TargetState int
declare @TargetS_S int = 1000030
declare @packetID int
declare @sourceGID nvarchar(100)

select @MTID = A.IMPMODELTYPE
      ,@TargetState = A.TARGETSTATE
	  ,@sourceGID=isnull(cast(C.GID as nvarchar(100)),'')
from PR_IMP_TRANS A with (nolock)
	left join PR_IMP_SOURCES C on A.DIRECTLINK=C.ID
where A.ID = @ImpTypeID

/*
@TargetState
0	Shipped* (default)
1	Imported
2	Production Completed
*/
if @TargetState = 1
  set @TargetS_S = 1000130
else if @TargetState = 2
  set @TargetS_S = 1000022
else    
  set @TargetS_S = 1000030

	if @sourceGID='C61C13A6-B291-471B-ABEB-72EA821382EA' /*'Import from US NT Data' - ищем по имени модели*/
		update ##temp_import_chip set MODELID = (select top 1 B.ID from PR_MODELS B where B.TYPEID = @MTID and B.NAME = ##temp_import_chip.PN collate database_default)
	else	/*остальные - ищем по PN*/
		update ##temp_import_chip set MODELID = (select B.ID from PR_MODELS B where B.TYPEID = @MTID and B.CODE = ##temp_import_chip.PN collate database_default)

/* Commented according to A.Khodakov request
update ##temp_import_chip set MODELID = (select B.ID from PR_MODELS B where B.TYPEID = @MTID and B.CODE = ##temp_import_chip.PN collate database_default)
update ##temp_import_chip set MODELID = (select top 1 B.ID from PR_MODELS B where B.TYPEID = @MTID and B.NAME = ##temp_import_chip.PN collate database_default)
 where MODELID is null
*/

delete from ##temp_import_chip where MODELID is null /*TODO сохранять в PR_IMP_PACKET_T с ошибкой отсутствия модели */

 
update ##temp_import_chip set DEVICEID = (select B.ID from PR_DEVICE B left join PR_MODELS M on B.MODELID = M.ID where M.TYPEID=@MTID and B.SN = ##temp_import_chip.SN collate database_default)

  --update ##temp_import_chip set DEVICEID = (select B.ID from PR_DEVICE B where B.MODELID = ##temp_import_chip.MODELID and B.SN = ##temp_import_chip.SN collate database_default)

delete from ##temp_import_chip_p where VNESHID in (select ID from ##temp_import_chip where DEVICEID is not null)
delete from ##temp_import_chip where DEVICEID is not null


if exists (select * from ##temp_import_chip A where A.DEVICEID is null)
begin


	insert into PR_IMP_PACKET (GID,S_S,S_CR,S_CDT,TYPEID,RECIEVED)
	values (newid(),1,@UserID,getdate(),@ImpTypeID,getdate())

	set @packetID = @@identity

	insert into PR_DEVICE (GID,S_CR,S_CDT,S_S,MODELID,SN,IMPPACKID,IMPID,TEMPID)
	select newid(),@UserID,getdate(),@TargetS_S,MODELID,SN,@packetID,@ImpTypeID,A.ID
	from ##temp_import_chip A 
	where A.DEVICEID is null
	
	insert into PR_IMP_PACKET_T (VNESHID,DEVICEID,IMPSTATE,IMPMODEL)
	select A.IMPPACKID,A.ID,1,B.PN
	from PR_DEVICE A with (nolock) 
	left join ##temp_import_chip B with (nolock) on B.ID = A.TEMPID
	where A.IMPPACKID = @packetID
	

	update ##temp_import_chip set DEVICEID = (select B.ID from PR_DEVICE B where B.MODELID = ##temp_import_chip.MODELID and B.SN = ##temp_import_chip.SN collate database_default)

	insert into PR_DEVICE_IN_VALUES (DEVICEID,PARAMID,PVALUE,PACKETID)
	select B.DEVICEID,A.PARAMID,A.PVALUE,@packetID
	from ##temp_import_chip_p A
	left join ##temp_import_chip B on B.ID = A.VNESHID
	where B.DEVICEID is not null
	
	update PR_IMP_PACKET set S_S = 1000067 /*loaded*/ where ID = @packetID
	
	update PR_DEVICE_IN_VALUES set INDEX_STR = upper(CAST(PVALUE AS nvarchar(200)))
    where PARAMID in (select B.PRMID from PR_IMP_INDEX_PRMS B)
      and PACKETID = @packetID
      and INDEX_STR is null

end

set nocount off