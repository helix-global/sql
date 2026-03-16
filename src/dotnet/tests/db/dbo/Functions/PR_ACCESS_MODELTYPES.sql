create function [dbo].[PR_ACCESS_MODELTYPES] (@aUserID int,@aMode int,@aDate datetime)
returns @res table (ID int)
as 
begin

insert into @res (ID) 
select A.ID from PR_MODELTYPE A with (nolock) 
where dbo.COM_DEP_ACCESS(null,A.DEPARTMENTID,@aMode,@aUserID,@aDate) = 1

return

end