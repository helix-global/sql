CREATE PROCEDURE [dbo].[MSG_REPLYWITHFILES_ADDCCGR] 
  @InMessageID int, @AddCCGroup int, @aAnswer varchar(max)
AS
BEGIN
  set nocount on

  declare @inFrom nvarchar(1024)
  declare @inSubj nvarchar(1024)
  declare @transID int
  
  select @inFrom = A.MSGFROM
       , @inSubj = isnull(A.MSGSUBJ,'')
       , @transID = A.TEMPID 
  from MSG_INBOX A with (nolock)
  where A.ID = @InMessageID

  declare @AddCC nvarchar(1024)

  select @AddCC = isnull(@AddCC,'') + C.EMAIL + '; '
  from dbo.DEF_USERSINGROUP(@AddCCGroup) A
  left join DEF_USERS B with (nolock) on B.ID = A.ID
  left join COM_EMPLOYEE C on C.ID = B.EMPLOYEEID
  where C.EMAIL is not null

  if @transID > 0
  begin
    declare @AddCC2 nvarchar(512)
    select @AddCC2 = A.ERRMSGCC from PR_IMP_TRANS A with (nolock) where A.ID = @transID
    set @AddCC2 = isnull(@AddCC2,'')
    if len(@AddCC2) > 0
    begin
       
       if len(@AddCC) > 0
          set @AddCC = isnull(@AddCC,'') + '; ' + @AddCC2
       else
          set @AddCC = @AddCC2
       
    end   
  end
  
  declare @ansID int
  
  INSERT INTO MSG_OUTGOING (S_S, GID, MSGTO, MSGSUBJ, MSGBODY, S_CDT, S_CR, MSGCC, INCOMINGID) 
  values (0,NEWID(),@inFrom,'Re: '+@inSubj,@aAnswer, GETDATE(), 0, @AddCC, @InMessageID)
  
  set @ansID = @@IDENTITY
  
  insert into MSG_OUT_ATTACHEMENTS (VNESHID,FILENAME,FILESIZE,FILEDATE,FILEBLOB)
  select @ansID,A.FILENAME,A.FILESIZE,A.FILEDATE,A.FILEBLOB
  from MSG_IN_ATTACHEMENTS A
  where A.VNESHID = @InMessageID
  
  update MSG_OUTGOING set S_S = 1 where ID = @ansID
  
  set nocount off 
END