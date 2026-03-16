
CREATE FUNCTION [dbo].[DA_CONCESSION_ACCESS_IDS](@UserID int)
returns @ret table (ID int)
as
begin

/* Проверка доступа к документу (список доступных для отображения ID документов */
/* Check access to the document (list of document IDs available for display */

	--test
	--declare @UserID int = 26052 --1293
	-- 1293 dep 146 Sergej Artjuhov
	--declare @ret table (ID int)

	
	/* ADD all doc if user in group CFR and exit */
	if(dbo.DEF_USERINGROUP7(@UserID, 'CFR') = 1 or dbo.DEF_USERINGROUP7(@UserID, 'CAD') = 1)
	begin
		insert into @ret
		Select 
			A.ID
		from 
			dbo.DA_CONCESSION A with(nolock) 

		--all docs
		return
	end
	
	
	/* All documents Where User in Approvers or Deputy and if in CDR group */
	--in approvers or deputy
	insert into @ret
	select ID from dbo.DA_CONCESSION_GET_ALL_DOCID_BY_USER(@UserID) 
	
	--in CDR group
	if(dbo.DEF_USERINGROUP7(@UserID, 'CDR') = 1)
	begin
		insert into @ret
		Select 
			A.ID
		from 
			dbo.DA_CONCESSION A with(nolock) 
			left join @ret R on R.ID=A.ID						-- ДЛЯ только которых нет 
		where 
			A.DEPID = dbo.COM_USER_DEPARTMENT(@UserID)
			and R.ID is null									-- только которых нет 
	end
	
	/* all where approved and if in CDR */
	return
end