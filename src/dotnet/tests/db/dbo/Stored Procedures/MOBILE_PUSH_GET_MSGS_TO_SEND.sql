-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[MOBILE_PUSH_GET_MSGS_TO_SEND] 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
		A.*,
		V.DBEG,
		V.DEND

	from 
		dbo.MOBILE_PUSH_MESSAGES A
		left join COM_VACATION V with (nolock) on V.ID = A.DOCID and A.DOCOID = 1000184
	where 
		isnull(ISSENDED, 0) = 0
		and
		ISNULL(A.CANCELED, 0) = 0

	union 

	/*AND for Transportation booking KB4439*/
	SELECT	
		B.*, NULL, NULL
	from 
		dbo.MOBILE_PUSH_MESSAGES B
	where
		B.PAYLOADCOMMAND like ('transportationrequest%')
		and
		isnull(B.ISSENDED, 0) = 0
		and
		ISNULL(B.CANCELED, 0) = 0

	SET NOCOUNT OFF;
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[MOBILE_PUSH_GET_MSGS_TO_SEND] TO [EMEA\DEXHZ]
    AS [dbo];

