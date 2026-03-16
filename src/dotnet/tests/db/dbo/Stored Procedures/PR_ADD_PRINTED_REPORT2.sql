create PROCEDURE [dbo].[PR_ADD_PRINTED_REPORT2]
(
    @reportId int,
    @operIds nvarchar(max),
    @userId int,
	@sessionId nvarchar(40)
)
AS
BEGIN

	if exists(select * from PR_PRINTED_REPORTS where SESSIONID=@sessionId)
		return
		
    
    insert into PR_PRINTED_REPORTS ( OPERID, REPORTID, S_CDT, S_CR, SESSIONID )
    select ID, @reportId, getdate(), @userId, @sessionId
        from dbo.COM_STR2TABLE_INT(@operIds)

END