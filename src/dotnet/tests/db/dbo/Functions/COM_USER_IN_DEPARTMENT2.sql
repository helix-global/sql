create FUNCTION [dbo].[COM_USER_IN_DEPARTMENT2] (@aUserID int, @depID int, @includeChDep int) 
RETURNS int
AS
BEGIN
   
   declare @userDepID int = dbo.COM_USER_DEPARTMENT(@aUserID)
   
   if @userDepID = @depID
     return 1
   
   if isnull(@includeChDep,0) = 1
   begin
   
      if exists (select ID from dbo.COM_GETCHILD_DEPARTMENTS2(@depID,0) where ID = @userDepID)
        return 1
      
      
   end
   
   return 0
   
END