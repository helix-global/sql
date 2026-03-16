CREATE function [dbo].[REP_LAST_NN] (@aReportOID int, @aUserID int)
returns int
as 
begin

  declare @res int
  select @res = A.LASTNN from REP_USERNUMBERS A with (nolock) 
   where A.REPORTOID = @aReportOID 
     and A.USERID = @aUserID
     and A.DD = CAST(GETDATE() as DATE)

  return @res
  
end