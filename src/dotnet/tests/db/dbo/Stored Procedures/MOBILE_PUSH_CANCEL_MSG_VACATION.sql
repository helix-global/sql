-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
CREATE PROCEDURE [dbo].[MOBILE_PUSH_CANCEL_MSG_VACATION]
	@VacationID int, @FromSite bit = 0
AS
BEGIN
	SET NOCOUNT ON;

	update 
		[dbo].[MOBILE_PUSH_MESSAGES] 
	set 
		CANCELED = 1,
		CANCELREASON = case when @FromSite= 1 then 'Cancel Apply from Site' else 'Cancel Apply from PDB' end
	where 
		DOCID = @VacationID

	SET NOCOUNT OFF;    
END