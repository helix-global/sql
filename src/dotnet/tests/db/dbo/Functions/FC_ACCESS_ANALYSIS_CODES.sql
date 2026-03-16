CREATE function [dbo].[FC_ACCESS_ANALYSIS_CODES] (@aUserID int,@aMode int,@aDate datetime)
returns @res table (ID int)
as 
begin

	/* добавлена доступность всех отделов если человек в группе "Human Reports Editor"*/
	/*Human Reports Editor group*/ --KB3821
	if dbo.DEF_USERINGROUP7(@aUserID,'HRE') =1
	begin
		insert into @res
		select ID from dbo.COM_DEPARTMENTS
	end
	else
	begin
	
		/* добавлены отделы на которые даны разрешения в FC_DEPSHARING */
		
		insert into @res (ID)
		select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,@aMode,@aDate) 
		
		
		   /*
		insert into @res (ID)
		select B.PARENTDEPARTMENT from COM_DEPARTMENTS B with (nolock) where B.ID in (select ID from @res) and B.PARENTDEPARTMENT is not null
		  */
		
		insert into @res (ID)
		select A.DEPID 
		from FC_DEPSHARING A with (nolock) 
		where A.ALLOW2DEPID in (select ID from @res)
		  and (A.ALLOW2EMPLID is null or A.ALLOW2EMPLID = dbo.DEF_EMPLOYEE(@aUserID))
		
		insert into @res (ID)
		select B.PARENTDEPARTMENT
		from FC_DEPSHARING A with (nolock) 
		left join COM_DEPARTMENTS B with (nolock) on B.ID = A.DEPID
		where A.ALLOW2DEPID in (select ID from @res)
		  and B.PARENTDEPARTMENT is not null
		  and A.ALLOW2EMPLID is null
	end
	
	return

end