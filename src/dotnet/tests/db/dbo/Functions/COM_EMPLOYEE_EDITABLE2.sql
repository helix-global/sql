CREATE function [dbo].[COM_EMPLOYEE_EDITABLE2](@aDepID int,@aUser int,@aMode int,@aDate datetime, @aAzubi int)
returns int as 
begin

  declare @res int
  select @res = dbo.COM_DEP_ACCESS(null,@aDepID,@aMode,@aUser,@aDate)
  if (isnull(@res,0) <> 1)
    select @res = dbo.DEF_USERINGROUP4(@aUser,'LA',@aDate)
  
  if (isnull(@res,0) <> 1) and (@aAzubi = 1)   /*KB523*/
  begin
     select @res = dbo.DEF_USERINGROUP4(@aUser,'AMR',@aDate)
  end
  
  if isnull(@res,0) <> 1 and dbo.DEF_USERINGROUP7(@aUser,'HR') = 1 and dbo.DEF_USERINGROUP7(@aUser,'HR-EE') = 1 /*KB4300*/
  begin
    declare @UserLocation int = dbo.COM_TOP_PARENT_DEPID(dbo.COM_USER_DEPARTMENT(@aUser))
	if @aDepID in (select ID from dbo.COM_GETCHILD_DEPARTMENTS2(@UserLocation,1))
	  set @res = 1
  end
  
  return @res
end