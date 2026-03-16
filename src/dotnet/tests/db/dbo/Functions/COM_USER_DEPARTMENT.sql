-- =============================================
-- Author:          Антон Граматкин
-- Create date: 17-10-2014
-- Description:     Возвращает подразделение, к которому принадлежит Пользователь
-- =============================================
CREATE FUNCTION [dbo].[COM_USER_DEPARTMENT]
(
       @USER_ID INT
)
RETURNS int
AS
BEGIN
       DECLARE @RESULT INT

       
       SELECT 
             @RESULT = DEP.ID    
       FROM DEF_USERS USR
       JOIN COM_EMPLOYEE EMP ON USR.EMPLOYEEID = EMP.ID
             JOIN COM_DEPARTMENTS DEP ON EMP.DEPID = DEP.ID
       WHERE
             USR.ID = @USER_ID

       
       RETURN @RESULT
END