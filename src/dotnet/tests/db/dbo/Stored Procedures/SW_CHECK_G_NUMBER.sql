create procedure [dbo].[SW_CHECK_G_NUMBER]
 @Number nvarchar(50), @RowID int, @GroupID int, @aMode int
as 
SET nocount on

  if exists (select B.ID from SW_GROUPS_SETTINGS B with (nolock) where B.SWGRID = @GroupID and isnull(B.DISABLE_AN,0) = 1)
     return
     
  exec PR_CHECK_G_NUMBER @Number, @RowID , @aMode 
       

SET nocount off