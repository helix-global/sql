
CREATE FUNCTION dbo.COM_DOC_METHOD_LAST_USER
(
	 @docOid int,
	 @docId int,
	 @methodOid int
)
RETURNS int
AS
BEGIN

	declare @userId int

	declare @lastId int
	select @lastId = MAX(ID) from DEF_LOG  with (nolock)
		where DOCOID=@docOid	
			and DOCID=@docId 
			and CAPTION like 'Document method proceed%(' + CAST(@methodOid as nvarchar(10)) + ')'

	select @userId = L.S_USERID
		from DEF_LOG L
		where L.ID=@lastId

	return @userId

END