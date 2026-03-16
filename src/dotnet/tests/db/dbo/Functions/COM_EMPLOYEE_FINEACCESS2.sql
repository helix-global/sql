CREATE function [dbo].[COM_EMPLOYEE_FINEACCESS2](@aDepID int, @aUserID int, @aMode int, @aDate datetime, @aAzubi int)
returns nvarchar(max)
as
begin

declare @res nvarchar(max)
set @res = ''

if isnull(@aAzubi,0) = 1 and dbo.DEF_USERINGROUP7(@aUserID,'AMR') = 1
	return null
	
if dbo.DEF_USERINGROUP7(@aUserID,'LA') = 1	
	return null

if dbo.COM_DEP_ACCESS(null,@aDepID,@aMode,@aUserID,@aDate) <> 1
begin

  if dbo.DEF_USERINGROUP7(@aUserID,'HR') = 1
  begin
  
	 if dbo.DEF_USERINGROUP7(@aUserID,'HR-EE') = 1 /*KB4300*/
	 begin
		declare @UserLocation int = dbo.COM_TOP_PARENT_DEPID(dbo.COM_USER_DEPARTMENT(@aUserID))
		if @aDepID in (select ID from dbo.COM_GETCHILD_DEPARTMENTS2(@UserLocation,1))
		  return null
	 end
  
     if dbo.DEF_USERINGROUP7(@aUserID,'HROHV') = 1
         return 'FullReadOnly;NoAllActions;BypassActionsMarked=Keep4HR;BypassActionsMarked=Keep4HROHV;';
     
     return 'FullReadOnly;NoAllActions;BypassActionsMarked=Keep4HR;';
  end   

  return 'FullReadOnly;NoAllActions;';
end
	                
if LEN(@res) = 0
   return null
     
return @res  

end;