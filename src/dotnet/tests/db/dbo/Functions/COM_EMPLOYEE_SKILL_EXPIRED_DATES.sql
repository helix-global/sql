CREATE function [dbo].[COM_EMPLOYEE_SKILL_EXPIRED_DATES]
( @depId int)
returns @ret table (EMPLOYEEID int, USERID int, SKILLID int, EXPIRED_DATE datetime, EXPIRED bit)
AS
begin

	--Даты истечения срока навыков по отделу на текущую дату

    insert into @ret
    select EMPLOYEEID, USERID, SKILLID, EXPIRED_DATE, EXPIRED 
        from COM_EMPLOYEE_SKILL_EXPIRED_DATES_BY_DATE2(@depId, getdate())

    return
end