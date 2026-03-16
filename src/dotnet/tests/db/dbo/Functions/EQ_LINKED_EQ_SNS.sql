
CREATE FUNCTION [dbo].[EQ_LINKED_EQ_SNS]
(
	@eqId int
)
RETURNS nvarchar(max)
AS
BEGIN
	
	DECLARE @ret nvarchar(max) = ''

	SELECT @ret = @ret + isnull(E.SN, '<No SN>') + ',' + CHAR(13) + CHAR(10)
		from EQ_EQUIPMENT_LINKED L
			join EQ_EQUIPMENT E on L.LINKED_EQID=E.ID
		where L.VNESHID = @eqId
		  and isnull(L.LINKDEND,'40000101') > getdate()

	if @ret <> ''
		set @ret = LEFT(@ret, len(@ret) - 3)

	RETURN @ret

END