CREATE function [dbo].[PR_DEVICE_SRV_PACKAGE] (@aDeviceID int,@aMode int,@aUserID int)
returns @res table (ID int identity,DEVICEID int,FILENAME nvarchar(255),FILEDATE datetime, FILESIZE int, FILEBLOB image, FILEDESC nvarchar(200),FILEGROUP nvarchar(200), FILEARCHIVEQUID int, FILEARCHIVEID int, FILEOBJECTID int)
as 
begin

if (@aMode = 1)
begin
 
  insert into @res(DEVICEID, FILENAME, FILEDATE, FILESIZE, FILEDESC, FILEARCHIVEQUID, FILEARCHIVEID, FILEOBJECTID, FILEGROUP)
  select A.ID, 
    case when C.FILENAME_MASK is null then C.NAME else dbo.PR_PROCESS_MACROS(C.FILENAME_MASK,A.ID,1) end+'.zip', 
    getdate(), dbo.PR_DEVICE_SRV_PACKAGE_SIZE(A.ID, C.ID), C.DESCSTR, 1001011 /*cs_service_package_get_files_query*/, C.ID, A.ID, D.NAME
  from PR_DEVICE A with (nolock)
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID
  left join CS_SRV_PACKAGE C with (nolock) on C.MTID = B.TYPEID
  left join COM_DEPARTMENTS D with (nolock) on D.ID = C.DEPID
  where A.ID = @aDeviceID
    and C.ID is not null

  delete from @res where FILESIZE = 0

end

return

end