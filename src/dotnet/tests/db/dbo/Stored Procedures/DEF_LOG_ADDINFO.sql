CREATE PROCEDURE [dbo].[DEF_LOG_ADDINFO] @aCaption nvarchar(400), @aDocOID int, @aDocID int 
AS
BEGIN

    declare @uid int = isnull(dbo.DEF_USERID(),0)
   
    insert into DEF_LOG (DD,LEV,CAPTION,S_USERID,EV_TYPE,DOCOID,DOCID)
    values (getdate(),1,@aCaption,@uid,75291,@aDocOID,@aDocID)


END