-- =============================================
-- Author:   Anton Gramatkin
-- Create date: 09-10-2014
-- Description:     Находит пользователя, который назначен на внешнюю операцию
-- =============================================
CREATE FUNCTION [dbo].[PR_EXTERNAL_OPERATION_USERID]
(
       @DEVICE_ID INT
       ,@OPERTYPE_ID INT
)
RETURNS INT
AS
BEGIN
       
       DECLARE @USER_ID INT

       SELECT TOP 1
             @USER_ID = ISNULL(USR.ID, -1)
       FROM [dbo].[PR_EXTERNAL_OPERATION] EXT
       JOIN [dbo].[PR_EXTERNAL_OPERATION_DEVICE_T] EXT_DEV ON EXT.ID = EXT_DEV.VNESHID
       JOIN [dbo].[PR_EXTERNAL_OPERATION_T] EXT_OPER ON EXT.ID = EXT_OPER.VNESHID
             JOIN DEF_USERS USR ON EXT_OPER.EMPLOYEEID = USR.EMPLOYEEID
       WHERE
             EXT_DEV.DEVICEID = @DEVICE_ID
       AND
             EXT_OPER.OPERTYPEID = @OPERTYPE_ID
       AND
             EXT.S_S = 1000129 /*applied*/
       ORDER BY EXT.ID DESC, USR.ID DESC

       RETURN @USER_ID

END