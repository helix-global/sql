


CREATE function [dbo].[MOBILE_VACATION_CANAPPROVEREJECT](@VacationID int, @UserID int)
returns int as
begin
	--DECLARE @VacationID int =  168468
	--DECLARE @UserID int = 998--1941 -- 998 --26052 -- 998 --26052

	DECLARE @res int = 0

	DECLARE @EmplID int  = (select top 1 V.EMPLID from COM_VACATION V where V.ID = @VacationID);
	DECLARE @UserDepID  int = (select top 1 E.DEPID from COM_EMPLOYEE E where E.ID = @EmplID);
	DECLARE @VacationUserID int = (select top 1 U.ID from DEF_USERS U where U.EMPLOYEEID = @EmplID);

	set @res = 		
	(select Count(*) CANAPPROVE
		from DEF_USERS U
			left join COM_EMPLOYEE E on E.ID = U.EMPLOYEEID
			left join DEF_USERSTOGROUP G on G.USERID = U.ID 
		where 
			E.DEPID = @UserDepID
			and 
			E.S_S = 1  /* valid */
			and
			G.GROUPID = 1114 /* HD&VICE role (can approve Absences) */
			and
			U.ID <> @VacationUserID /*Do not send to yourself*/
			and 
			U.ID = @UserID
			)

		-- set @res = 1
	return @res
end