CREATE function dbo.PR_DEVICE_FILES_NOBLOB (@aDeviceID int,@aMode int,@aUserID int)
returns @res table (ID int identity,SOURCEID int,DEVICEID int,FILENAME nvarchar(255),FILEDATE datetime, FILESIZE int, FSOURCE int, FILEPREVIEW image, FILEGROUP nvarchar(200), FILEDESC nvarchar(200), FILEBLOBQUERYOID int, FILEBLOB image)
as 
begin

/*
@aMode 
1 - files from shared parameterss

*/

if (@aMode = 1)
begin
 
  insert into @res(SOURCEID,DEVICEID,FILENAME,FILEDATE, FILESIZE,  FSOURCE, FILEPREVIEW, FILEGROUP, FILEDESC, FILEBLOBQUERYOID)
  select B.ID,A.ID,B.FILENAME,B.FILEDATE,B.FILESIZE,B.FSOURCE,B.FILEPREVIEW,A4.NAME,A3.NAME,1001076
  from PR_DEVICE A with (nolock)
  left join PR_MODELS A2 with (nolock) on A2.ID = A.MODELID
  left join PR_MODELTYPE_PARAMS A3 with (nolock) on A3.TYPEID = A2.TYPEID
  left join PR_MODELTYPE_PARAMS_GR A4 with (nolock) on A4.ID = A3.PGROUP
  cross apply dbo.PR_DEVICE_PARAM_FILES_NOBLOB (A.ID,A3.ID) B
  where A.ID = @aDeviceID
    and A3.DATATYPE in (7,8,10) /*file,pict,SW&T*/
    and isnull(A3.SHAREPRM,0) = 1
  

end

return

end