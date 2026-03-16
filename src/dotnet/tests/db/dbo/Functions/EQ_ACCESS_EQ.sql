CREATE function [dbo].[EQ_ACCESS_EQ] (@aUserID int,@aMode int,@aDate datetime)
returns @res table (ID int)
as 
begin

declare @onlyOwned int = dbo.DEF_USERINGROUP7(@aUserID,'OPEqWm')  /*KB2203*/

if @onlyOwned = 1
begin
	insert into @res (ID) 
	select A.ID
	from EQ_EQUIPMENT A with (nolock) 
	where A.DEPID in (SELECT ID FROM dbo.COM_ACCESS_DEPARTMENTS(@aUserID, 13, @aDate)) 
end
else
begin
	insert into @res (ID) 
	select distinct A.ID
	from
    EQ_EQUIPMENT A with (nolock) 
    join EQ_MODELS EM with (nolock) on EM.ID = A.EQMODELID
    join EQ_TYPES ET with (nolock) on ET.ID = EM.EQTYPEID
	where A.DEPID in (SELECT ID FROM dbo.COM_ACCESS_DEPARTMENTS(@aUserID, 13, @aDate)) 
    -- Azure#6062: allow access to equipment from all other departments where equipment type has specific shared flag. If someone wants to see only equipment from own department - see previous block (specific user group)
	  or (isnull(ET.SHAREDTYPE,0)=1 /* 0 - none, 1 - shared visible in all departments */ and isnull(A.SHAREMODE,0) = 0 /* 0 - default, 1 - not visible*/)
end
	
return

end