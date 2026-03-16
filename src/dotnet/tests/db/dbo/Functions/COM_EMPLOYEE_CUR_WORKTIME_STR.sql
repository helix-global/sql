CREATE FUNCTION [dbo].[COM_EMPLOYEE_CUR_WORKTIME_STR]
(
	@empId int
)
RETURNS nvarchar(1000)
AS
BEGIN
	
	declare @ret nvarchar(1000) = '', @wtId int

	select @ret = isnull(@ret + T.NAME + char(13) + char(10) + char(13) + char(10),''), @wtId = T.ID
		from COM_WORKTIME T 
			join COM_EMPLOYEE E on T.ID=E.PERSONALWT
		where E.ID=@empId

	if @wtId is null
		select @ret = isnull(@ret + T.NAME + char(13) + char(10) + char(13) + char(10),''), @wtId = T.ID
			from COM_WORKTIME T 
				join COM_DEPARTMENTS D on T.DEPID=D.ID
				join COM_EMPLOYEE E on D.ID=E.DEPID
			where E.ID=@empId and T.WTDEFAULT=1

	select @ret = @ret + cast(W.WTURN as nvarchar(2)) + ':   ' + SUBSTRING(cast(cast(W.TFROM as time) as nvarchar(10)),1,5) + ' - ' + 
						SUBSTRING(cast(cast(W.TTO as time) as nvarchar(10)),1,5) + char(13) + char(10)
		from COM_WORKTIME_BR W
		where W.VNESHID=@wtId

	return @ret

END