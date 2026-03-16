CREATE FUNCTION [dbo].[PR_SERVICE_ORDER_FINEACCESS]
(
		@DocumentId INT
		,@UserId INT
		,@Date DATETIME
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @RES NVARCHAR(MAX)
			,@DepartmentFromId INT
			,@DepartmentToId INT
			,@EmployeeDepartmentId INT
			,@State INT

	SELECT @EmployeeDepartmentId = [dbo].[COM_USER_DEPARTMENT](@UserId);
	SELECT 
		@DepartmentFromId  = FROMDEPID
		,@DepartmentToId = DEPARTMENTID
		,@State = S_S
	FROM PR_PRORDER
	WHERE
		ID = @DocumentId

		
	IF @DepartmentFromId IS NOT NULL/*все проверки только для Placed Service Order*/
	BEGIN
		IF dbo.COM_DEP_ACCESS(null,@DepartmentFromId,3,@UserId,@Date) = 1 /*если к Placed Service Order обращается сотрудник подразделения, которое его создало*/	
		BEGIN
			IF @State = 1000143 /*Approved*/ 
			BEGIN
					SET @RES = ';FullReadOnly;NoActionsMarked=CANNOT_PROCEED;'
			END
			ELSE IF @State = 1000035 /*если Сервисный заказ запущен, разместивший отдел не может его изменять*/ 
			BEGIN
				SET @RES = ';FullReadOnly;NoActionsMarked=CANNOT_CANCEL;NoActionsMarked=CANNOT_COMPLETE;'
			END
		END
		ELSE IF dbo.COM_DEP_ACCESS(null,@DepartmentToId,3,@UserId,@Date) = 1
		BEGIN
			IF @State = 1
				SET @RES = ';FullReadOnly;NoAllActions;'
			ELSE IF @State = 1000143 /*Approved*/ 
				SET @RES = ';NoActionsMarked=CANNOT_CANCELAPPROVE;'
			ELSE IF @State = 1000144 /*Approving expected*/ 
				SET @RES = ';NoActionsMarked=CANNOT_APPROVE;NoActionsMarked=CANNOT_APPREPORT;FullReadOnly;'
		END
	END

	IF LEN(@RES) = 0
		RETURN NULL

	RETURN @RES
END

-- SELECT [dbo].[PR_SERVICE_ORDER_FINEACCESS](68354, 22, getdate())