-- =============================================
-- Author:          Антон Граматкин
-- Create date: 17-10-2014
-- Description:     Возвращает ID подразделения, к которому принадлежит операция.
-- =============================================
CREATE FUNCTION [dbo].[PR_OPERATION_DEPARTMENT]
(
       @OPERATION_ID INT
)
RETURNS INT
AS
BEGIN
       DECLARE @RESULT INT

       SELECT 
             @RESULT = OP_TP_GR.DEPARTMENTID
       FROM PR_OPERATION OP with (nolock)
       LEFT JOIN PR_OPERATIONS OP_TP with (nolock) ON OP.OPERTYPEID = OP_TP.ID
             LEFT JOIN PR_OPERATIONS_GR OP_TP_GR with (nolock) ON OP_TP.OPERGRID = OP_TP_GR.ID
       WHERE
             OP.ID = @OPERATION_ID
       RETURN @RESULT
END