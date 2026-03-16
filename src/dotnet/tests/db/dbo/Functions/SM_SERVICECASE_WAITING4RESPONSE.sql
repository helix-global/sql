CREATE FUNCTION [dbo].[SM_SERVICECASE_WAITING4RESPONSE] (@CaseID int)
RETURNS int
AS
BEGIN

   declare @direction int
   
   select top 1 @direction = A.SCDIRECTION 
   from SM_SERVICECALL A with (nolock)
   where A.CASEID = @CaseID
     order by A.ID desc 
   
   if @direction = 2 /*outgoing*/
     return 1

   return null
END