
CREATE FUNCTION SW_PARENT_TAGS
(
	@fId int
)
RETURNS nvarchar(1000)
AS
BEGIN
	declare @ret nvarchar(1000) = ''

	declare @parentId int

	select @parentId = S.PARENTID
		from SW_STORAGE S
		where S.ID=@fId

	if @parentId is null
		return @ret

	while @parentId is not null
	begin

		select @ret = @ret + ISNULL(S.TAGS + ' ',''), @parentId=S.PARENTID
			from SW_STORAGE S
			where S.ID=@parentId

	end

	return @ret

END