CREATE PROCEDURE [dbo].[SM_REQUEST_RMA_2NAVI] @ServCaseID int, @UserID int
WITH EXECUTE AS OWNER , RECOMPILE
as 
BEGIN
  set nocount on


  declare @respCode nvarchar(10)
  /*
  select top 1 @respCode = isnull(CC.CODE,'NA') 
  from SM_SERVICECASE_ITEMS AA
  left join PR_MODELS BB with (nolock) on BB.ID = AA.MODELID
  left join COM_DEPARTMENTS CC with (nolock) on CC.ID = BB.DEPID
  where AA.VNESHID = @ServCaseID
    and CC.ID is not null
  */
  select top 1 @respCode = isnull(CC.CODE,'NA') 
  from SM_SERVICECASE AA
  left join COM_DEPARTMENTS CC with (nolock) on CC.ID = isnull(AA.RESPSERV, AA.SDEPID)
  where AA.ID = @ServCaseID
    and CC.ID is not null
  

  declare @reqID int

  insert into PDB_BUFFER..SERVICEREQUEST (S_S,SDEPID,S_CR,S_CDT,DESCRIPTION,RESPONSIBILITY,SERVICEORDERTYPE,CUSTOMERNO,CUSTOMERGUID,ORDERDATETIME,INTERNALREFERENCE,COMMENT,SCASEID,SCASE_CREATED)
  select 1000197,A.SDEPID,@UserID,getdate(),substring(A.SUBJ,1,50)
     ,@respCode
     ,case A.RMA_SC_TYPE when 1 then 'RMA' when 2 then 'SC' when 3 then 'SCAFF' when 4 then 'INT' end
     ,null --C.CODE
     ,C.CRMGUID
     ,getdate()
     ,A.ND
     ,cast(A.REMARK as nvarchar(100))
     ,A.ID
     ,A.S_CDT
  from SM_SERVICECASE A
  left join COM_CUSTOMER C on C.ID = isnull(CUSTID_4SERVORD,A.CUSTID)
  where A.ID = @ServCaseID
  
  set @reqID = @@identity
  
  insert into PDB_BUFFER..SERVICEREQUESTLINES(HEADERID,ITEMNO,SERIALNO,SCASEITEMID)
  select @reqID,B.CODE,A.SN,A.ID
  from SM_SERVICECASE_ITEMS A
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID
  where A.VNESHID = @ServCaseID

  insert into PDB_BUFFER..SERVICEREQUESTFILES(HEADERID,S_CR,S_CDT,FILENAME,FILESIZE,FILEDESC,FILEDATE,FILEBLOB,FILEPREVIEW)
  select @reqID,@UserID,getdate(),A.FILENAME,A.FILESIZE,A.FILEDESC,A.FILEDATE,A.FILEBLOB,A.FILEPREVIEW
  from SM_SERVICECASE_FILES A
  where A.VNESHID = @ServCaseID


  set nocount off

END