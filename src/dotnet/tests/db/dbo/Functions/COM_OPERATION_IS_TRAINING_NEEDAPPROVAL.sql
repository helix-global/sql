CREATE FUNCTION [dbo].[COM_OPERATION_IS_TRAINING_NEEDAPPROVAL]( @operID int, @UserInTrain int, @mode int)
RETURNS int
AS
BEGIN

  if @UserInTrain is null  /*для ускорения*/
     return 0
  

  declare @trOperID int
  select top 1 @trOperID = A.ID
  from COM_TRAINING_OPERATIONS A with (nolock)
  left join COM_TRAINING B with (nolock) on B.ID = A.TRAININGID
  where A.OPERID = @operID
    and B.S_S = 4760003 /*completed but not approved yet*/ 

  if @trOperID is not null
     return 1  


  select top 1 @trOperID = A.ID
  from COM_TRAINING_PREPARATORY A with (nolock)
  left join COM_TRAINING B with (nolock) on B.ID = A.TRAINING_ID
  where A.OPERID = @operID
    and B.S_S = 4760003 /*completed but not approved yet*/ 

  if @trOperID is not null
     return 1  


  select top 1 @trOperID = A.ID
  from COM_TRAINING_MAINTENANCE A with (nolock)
  left join COM_TRAINING B with (nolock) on B.ID = A.TRAININGID
  where A.OPERID = @operID
    and B.S_S = 4760003 /*completed but not approved yet*/ 

  if @trOperID is not null
     return 1  


  return 0

END