create PROCEDURE [dbo].[PU_CHECK_BATCH_NUMBER_BYCODE] @aCode nvarchar(50), @aBatchN nvarchar(100)
AS
BEGIN

  if @aBatchN = 'NA' /*для старых, не прошедших процедуру присвоения*/
    return


  declare @mode int
  declare @code nvarchar(100)
  declare @aModelID int
  
  select top 1 @mode = A.BATCH_MODE 
        ,@code = B.CODE
        ,@aModelID = A.MODELID
  from PU_BATCH_TR_MODELS A with (nolock)   
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID
  where B.CODE = @aCode
  
  if isnull(@mode,0) = 0
    return
    
  
  declare @mess nvarchar(max)
  
  if @mode > 0 and (@aBatchN is null or len(ltrim(rtrim(@aBatchN))) = 0)
  begin
     
    set @mess = 'Please provide batch number for batch tracked item "'+@code+'".'
    raiserror(@mess,16,0)
  
  end
  
  if @mode = 2
  begin
    
    if not exists  (select A.ID from PU_BATCHES A where A.MODELID = @aModelID and A.NN = @aBatchN)
    begin
       set @mess = 'Batch number "'+isnull(@aBatchN,'NA')+'" not found for batch tracked item "'+@code+'".'
       raiserror(@mess,16,0)
    end
  
  end

END