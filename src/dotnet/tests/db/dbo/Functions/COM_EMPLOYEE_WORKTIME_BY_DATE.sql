CREATE FUNCTION [dbo].[COM_EMPLOYEE_WORKTIME_BY_DATE] 
(
	@emplId int, @date datetime
)
RETURNS int
AS
BEGIN
	declare @ret int

	select top 1 @ret = H.PERSONALWT
		from COM_PERSONALWORKTIME_HISTORY H with (nolock)
		where H.DBEG<=@date and H.EMPLOYEEID=@emplId
		order by H.DBEG desc

	if @ret is null
		select top 1 @ret = W.ID
			from COM_WORKTIME W with (nolock)
				join COM_EMPLOYEE E with (nolock) on E.DEPID=W.DEPID and isnull(W.WTDEFAULT,0) = 1
			where E.ID=@emplId

	return @ret
END