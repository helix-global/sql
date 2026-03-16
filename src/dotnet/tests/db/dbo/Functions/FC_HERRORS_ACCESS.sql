
/* KB3821 acces to all departments if user in "Human Reports Editor" group*/
CREATE function [dbo].[FC_HERRORS_ACCESS] (@UserID int,@aMode int,@aDate datetime)
returns @res table (ID int)
as 
begin



/* TEST DATA */
--declare @UserID int = 1864
--declare @aMode int = 3
--declare @aDate Date = GetDate()


if dbo.DEF_USERINGROUP7(@UserID,'HRE') =  0
begin 
	-- get DEPIDS as usually by access rights
	insert into @res
	select ID from dbo.COM_ACCESS_DEPARTMENTS(@UserID,@aMode,@aDate)
end
else
begin
	-- user in group "Human Reports Editor" and has access to ALL departments
	insert into @res
	select ID from dbo.COM_DEPARTMENTS
end

return

end