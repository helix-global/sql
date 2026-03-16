CREATE PROCEDURE [dbo].[FC_RECALC_FAILURERATE_FRID]  @aFRID int
AS
BEGIN
  set nocount on

  declare @ProductionDate datetime
  declare @modelID int 
  
  select @ProductionDate = coalesce(C.COMPLETED_DT,A.DATE_PRODUCT3,C.FAILED_DT)
        ,@modelID = A.MODELID
  from FC_REPORT A with (nolock)
  left join PR_DEVICE C with (nolock) on C.ID = A.DEVICEID
  where A.ID = @aFRID   
  
  if @ProductionDate is not null
  begin
     exec FC_RECALC_FAILURERATES @ProductionDate, @modelID, 0
  end 

   set nocount off
END