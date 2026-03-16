-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[COM_DEPARTMENTS_BY_PARENT_ID]
(	
	@parentDepId nvarchar(100)
)
RETURNS TABLE 
AS
RETURN 
	with S (ID, CODE) as 
		(select D.ID, D.CODE
		from COM_DEPARTMENTS D
		where D.ID=@parentDepId
		union all
		select D.ID, D.CODE
		from COM_DEPARTMENTS D
			join S on S.ID=D.PARENTDEPARTMENT)
		select ID, CODE
		from S