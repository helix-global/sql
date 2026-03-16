-- =============================================
-- Author:		А. Граматкин
-- Create date: 17.04.2015
-- Description:	Отдаёт сотрудников указанного отдела, которые на указанную дату были созданы, не были уволены и участвовали в производстве. 
-- =============================================
CREATE FUNCTION COM_EPLOYEES_IN_PRODUCTION
(	
	@Department int
	,@Date Date
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
		ID
	FROM COM_EMPLOYEE WITH(NOLOCK)
	WHERE
		DEPID = @Department
	AND
		ISNULL(NOPROD, 0) != 1
	AND
		S_CDT <= @Date
	AND
		(DISSDATE > @Date OR DISSDATE IS NULL)
)