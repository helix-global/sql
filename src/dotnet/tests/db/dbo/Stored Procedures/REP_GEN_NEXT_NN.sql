CREATE procedure [dbo].[REP_GEN_NEXT_NN] 
  @ReportOID int
 ,@UserID int
as 
SET nocount on

  declare @dd datetime
  set @dd = cast(GETDATE() as DATE)
  update REP_USERNUMBERS set LASTNN = LASTNN + 1
  where REP_USERNUMBERS.REPORTOID = @ReportOID 
    and REP_USERNUMBERS.USERID = @UserID
    and REP_USERNUMBERS.DD = @dd
    
  if @@ROWCOUNT = 0
  begin
    
    insert into REP_USERNUMBERS(REPORTOID,USERID,DD,LASTNN)
    values (@ReportOID,@UserID,@dd,1)  
    
  end

SET nocount off