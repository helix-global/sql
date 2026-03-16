create function [dbo].[EQ_ACCESS_EQFR] (@aUserID int,@aMode int,@aDate datetime)
returns @res table (ID int)
as 
begin

insert into @res (ID) 
	select A.ID 
	from EQ_FR A with (nolock) 
	where A.DEPID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,1,@aDate) )
union
	select A.ID 
	from EQ_FR A with (nolock) 
	left join EQ_EQUIPMENT B with (nolock) on B.ID = A.EQID
	where B.DEPID in (SELECT ID FROM dbo.COM_ACCESS_DEPARTMENTS(@aUserID, 13, @aDate))
union
	select A.ID 
	from EQ_FR A with (nolock) 
	left join EQ_EQUIPMENT B with (nolock) on B.ID = A.EQID
	left join EQ_MODELS T1002814 with (nolock) on T1002814.ID = B.EQMODELID
	where T1002814.DEPID in (SELECT ID FROM dbo.COM_ACCESS_DEPARTMENTS(@aUserID, 13, @aDate))  
	  and isnull(B.SHAREMODE,0) <> 1 

return

end