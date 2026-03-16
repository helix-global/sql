

CREATE FUNCTION dbo.PR_BOMITEM_DEVICES_INSTALL
(
	@partId int, @bomId int
)
RETURNS @res table (DEVICEID int, BOMID int, PARTQUANTITY decimal(20,10), OPERID int)
AS
BEGIN
	
	insert into @res (DEVICEID, BOMID, PARTQUANTITY, OPERID)
	select distinct O.DEVICEID, I.BOMID, I.PARTQUANTITY, I.OPERID
		from PR_OPERATION O
			join PR_OPERATION_INSTALL I on O.ID=I.OPERID
		where I.PARTID=@partId and (I.BOMID=@bomId or @bomId is null)
	RETURN 
END