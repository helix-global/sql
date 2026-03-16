CREATE PROCEDURE [dbo].[IMS_KB3491STATESCHANGE] @UserID int, @aMode int
AS
BEGIN
  /* KB3491 - авто перевод Training* и Training* inside departments в Completed */

  set nocount on

  declare @now datetime
  set @now = GETDATE()
  
  update IMS_TRAINING_SCHEDULE set S_S = 2130083 /*completed*/, S_MDT = @now, S_MR = @UserID
   where isnull(TRAINING_INSIDEDEP,0) = 0
     and S_S <> 2130083
     and S_S = 2130028 /*KB3673*/
     and @now > (select max(G.DD_END) 
                   from IMS_TRAINING_SCHEDULE_DATES G with(nolock) 
                   where G.VNESHID = IMS_TRAINING_SCHEDULE.ID
                 ) 


  update IMS_TRAINING_SCHEDULE set S_S = 2130084 /*completed*/, S_MDT = @now, S_MR = @UserID
   where isnull(TRAINING_INSIDEDEP,0) = 1
     and S_S <> 2130084
     and S_S = 5150002 /*KB3673*/
     and @now > TRAINING_INSIDEDEP_ENDDT
     
  
  set nocount off

END