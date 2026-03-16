CREATE FUNCTION [dbo].[VR_GET_REQUEST_ALL_VISITORS]
(
	@RequestID int
)
RETURNS nvarchar(100)
AS
BEGIN
  
	/* KB 4905 */

	
	--return (select dbo.GROUP_CONCAT(VISISTOR_NAME) from VR_REQUEST_VISITORS where VNESHID = @RequestID)

	return (
			select dbo.GROUP_CONCAT(
				convert(nvarchar(1000),V.VISISTOR_NAME) + 
				ISNULL( ' (' + V.JOB_TITLE + ')','') 
				)
			from dbo.VR_REQUEST_VISITORS V where V.VNESHID = @RequestID
		)

END