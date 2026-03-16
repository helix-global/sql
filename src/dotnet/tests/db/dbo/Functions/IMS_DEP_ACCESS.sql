CREATE function [dbo].[IMS_DEP_ACCESS](@aDepID int,@aMode int,@aUser int,@aDate datetime)
returns int as 
begin
  
  
  declare @res int

  set @res = dbo.COM_DEP_ACCESS(null,@aDepID,@aMode,@aUser,@aDate)
  
  if isnull(@res,0) <> 1 and dbo.DEF_USERINGROUP7(@aUser,'IMSFKB3514') = 1
     return 1
  
  return @res;
  
end