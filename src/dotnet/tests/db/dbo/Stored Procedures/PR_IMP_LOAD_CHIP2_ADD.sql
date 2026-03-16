CREATE procedure [dbo].[PR_IMP_LOAD_CHIP2_ADD]  @ImpTypeID int, @UserID int
as 
set nocount on

/* процедура только добавляет параметры (изделия не добавляет) */

declare @MTID int
declare @TargetState int
declare @TargetS_S int = 1000030
declare @packetID int

select @MTID = A.IMPMODELTYPE
      ,@TargetState = A.TARGETSTATE
from PR_IMP_TRANS A with (nolock)
where A.ID = @ImpTypeID

update ##temp_import_chip set DEVICEID = (select A.ID from PR_DEVICE A with (nolock) left join PR_MODELS B with (nolock) on B.ID = A.MODELID where B.TYPEID = @MTID and A.SN = ##temp_import_chip.SN collate database_default)

delete from ##temp_import_chip_p where VNESHID in (select ID from ##temp_import_chip where DEVICEID is null)
delete from ##temp_import_chip where DEVICEID is null
/*не вставлять дубли значений*/
delete from ##temp_import_chip_p where ID in (
	select A.ID
	from ##temp_import_chip_p A
	left join ##temp_import_chip B on B.ID = A.VNESHID
	where A.PVALUE = (select top 1 J.PVALUE from PR_DEVICE_IN_VALUES J where J.DEVICEID = B.DEVICEID and J.PARAMID = A.PARAMID order by J.ID desc) 
)

insert into PR_IMP_PACKET (GID,S_S,S_CR,S_CDT,TYPEID,RECIEVED)
values (newid(),1,@UserID,getdate(),@ImpTypeID,getdate())

set @packetID = @@identity

insert into PR_IMP_PACKET_T (VNESHID,DEVICEID,IMPSTATE)
select @packetID,A.DEVICEID,3
from ##temp_import_chip A with (nolock) 

insert into PR_DEVICE_IN_VALUES (DEVICEID,PARAMID,PVALUE,PACKETID)
select B.DEVICEID,A.PARAMID,A.PVALUE,@packetID
from ##temp_import_chip_p A
left join ##temp_import_chip B on B.ID = A.VNESHID
where B.DEVICEID is not null

update PR_IMP_PACKET set S_S = 1000067 /*loaded*/ where ID = @packetID

update PR_DEVICE_IN_VALUES set INDEX_STR = upper(CAST(PVALUE AS nvarchar(200)))
where PARAMID in (select B.PRMID from PR_IMP_INDEX_PRMS B with (nolock))
  and PACKETID = @packetID
  and INDEX_STR is null

set nocount off