CREATE function [dbo].[COM_EMPLOYEE_SKILL_LAST_DATES]
( @depId int)
returns @ret table (EMPLOYEEID int, USERID int, SKILLID int, LAST_DATE datetime)
AS
begin
	--Последние даты выполнения операций с использованием навыка на текущую дату

    insert into @ret
    select EMPLOYEEID, USERID, SKILLID, LAST_DATE
    from dbo.COM_EMPLOYEE_SKILL_LAST_DATES_BY_DATE(@depId, getdate())

    return
end