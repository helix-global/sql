CREATE PROCEDURE [dbo].[PU_CHECK_BATCH_NUMBER] @aModelID int, @aBatchN nvarchar(100)
AS
BEGIN

  set nocount on

  if @aBatchN = 'NA' /*для старых, не прошедших процедуру присвоения*/
    return


  declare @mode int
  declare @code nvarchar(100)
  
  select @mode = A.BATCH_MODE 
        ,@code = B.CODE
  from PU_BATCH_TR_MODELS A with (nolock)   
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID
  where A.MODELID = @aModelID
  
  if isnull(@mode,0) = 0
    return
    
  
  declare @mess nvarchar(max)
  
  if @mode > 0 and (@aBatchN is null or len(ltrim(rtrim(@aBatchN))) = 0)
  begin
     
    set @mess = 'Please provide batch number for batch tracked item "'+@code+'".'
    raiserror(@mess,16,0)
    set nocount off
    return
  
  end
  
  if @mode = 2
  begin
    
    if not exists  (select A.ID from PU_BATCHES A where A.MODELID = @aModelID and A.NN = @aBatchN)
    begin
       set @mess = 'Batch number "'+isnull(@aBatchN,'NA')+'" not found for batch tracked item "'+@code+'".'
       raiserror(@mess,16,0)
    end
  
  end
  
  set nocount off

END