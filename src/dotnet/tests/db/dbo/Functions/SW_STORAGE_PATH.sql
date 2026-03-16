
CREATE FUNCTION SW_STORAGE_PATH
(
	@fileId int
)
RETURNS nvarchar(2000)
AS
BEGIN
	
	declare @path nvarchar(2000) = ''
	declare @parentFileId int

	select @parentFileId = S.PARENTID, @path = '/' + S.FILENAME 
		from SW_STORAGE S
		where S.ID=@fileId

	while @parentFileId is not null
	begin
		select @parentFileId = S.PARENTID, @path = '/' + S.FILENAME  + @path
			from SW_STORAGE S
			where S.ID=@parentFileId
	end

	return @path

END