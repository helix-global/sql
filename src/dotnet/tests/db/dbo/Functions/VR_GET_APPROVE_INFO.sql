
CREATE FUNCTION [dbo].[VR_GET_APPROVE_INFO]
(
	@RequestID int
)
RETURNS nvarchar(MAX)
AS
BEGIN
  
	/* KB 4905 */

	declare @delimiter nvarchar(2) = CHAR(10) -- + CHAR(13)
	
	return (
		select
			dbo.GROUP_CONCAT_D(
		case 
			when CAPTION like '%5130018%' then 'HoD'
			when CAPTION like '%5130019%' then 'MD'
			else ''
		end +
		
		' approved by: ' + U.FULLNAME + @delimiter +

		case 
			when CAPTION like '%5130018%' then 'HoD'
			when CAPTION like '%5130019%' then 'MD'
			else ''
		end +
		
		' approved time: ' + dbo.COM_FORMAT_DATETIME(L.DD,1) 

		, @delimiter + @delimiter) as INFO
	
		from 
			DEF_LOG L with (nolock) 
			left join DEF_USERS U with (nolock) on U.ID = S_USERID
		
		where 
			L.DOCOID = 5130009 /* vr_request */
			and
			L.DOCID = @RequestID
			and 
			L.EV_TYPE = 20002
			and CAPTION like '%Approve%'
			)

END