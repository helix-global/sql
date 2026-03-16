
CREATE function [dbo].[COM_VR_REQUEST_FINEACCESS](@aUserID int, @aCreator int, @aDEPID int)
returns nvarchar(200) as 
begin

declare @res nvarchar(200) = null

-- only if you are request starter (owner)
if @aUserID <> @aCreator
  set @res = isnull(@res,'')+ 'NoActionsMarked=CAN_ONLY_AUTHOR;'



--if(isnull((select TOP 1 E.DEPID from dbo.DEF_USERS U with (nolock) left join dbo.COM_EMPLOYEE E with (nolock) on U.EMPLOYEEID = E.ID where U.ID = @aUserID),0) <> @aDEPID) -- only if you are in request DEP
/* KB4997 - for all Parent deps also */
if (dbo.COM_USER_DEPARTMENT(@aUserID) not in (select ID from COM_GETPARENT_DEPARTMENTS(@aDEPID,1)))
	set @res = isnull(@res,'') + 'NoActionsMarked=CAN_ONLY_DEP;'

     
return @res

end;