create PROCEDURE [dbo].DEF_UPD_DOMAINNAME 
  @UserID int
AS
BEGIN

   
    update DEF_USERS set LOGINNAME = LOGINNAME2 
    where ID = @UserID 
      and upper(LOGINNAME2) = upper(ORIGINAL_LOGIN())
      and upper(LOGINNAME) <> upper(ORIGINAL_LOGIN())
   


END