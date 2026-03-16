create function [dbo].[COM_EMPLOYEE_EDITABLE](@aDepID int,@aUser int,@aMode int,@aDate datetime)
returns int as 
begin
  declare @res int
  select @res = dbo.COM_DEP_ACCESS(null,@aDepID,@aMode,@aUser,@aDate)
  if (isnull(@res,0) <> 1)
    select @res = dbo.DEF_USERINGROUP4(@aUser,'LA',@aDate)
  return @res
end