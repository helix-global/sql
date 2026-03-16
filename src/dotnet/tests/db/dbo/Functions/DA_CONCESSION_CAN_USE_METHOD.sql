


--declare @ContextID nvarchar(max) = '49, 56'

--Can Approve

--select * from DA_CONCESSION

CREATE function [dbo].[DA_CONCESSION_CAN_USE_METHOD](@UserID int, @DocID int)
returns int as 
begin

/**/
	
	--5290008	Waiting for approval
--5290009	Waiting for QM approval
--5290010	Waiting for PLM approval
--5290011	Waiting for MD approval
	--5290012	Rejected
	--5290013	Approved


--10	Issued - 
--20	Checked
--30	QM
--40	PLM
--50	MD


	
	--declare @DocID int = 56
	--declare @UserID int = 26052 -- Iam
	--declare @UserID int = 33592 --Vlad
	--declare @UserID int = 22279 --Goga
	--declare @UserID int = 20674 --Serega 2662
	


	declare @res int = 0
	declare @UsersIDs table (USERID int, EMPLID int, AUTHTYPE int, REMARK nvarchar(100))
	
	/* Get userID that can Approve/Reject Documnet in curretn State */
	insert into @UsersIDs
	Select 
		 case 
			when DA.S_S = 5290009 then dbo.COM_USER_BY_EMPL(DA.CHECKEDID) 
			when DA.S_S = 5290010 then dbo.COM_USER_BY_EMPL(DA.RELEASEDID) 
			when DA.S_S = 5290011 then dbo.COM_USER_BY_EMPL(DA.APPROVEDID) 
			else 0
		end as USERID,
		 case 
			when DA.S_S = 5290009 then DA.CHECKEDID 
			when DA.S_S = 5290010 then DA.RELEASEDID 
			when DA.S_S = 5290011 then DA.APPROVEDID 
			else 0
		end as EMPLID,
		case
			when DA.S_S = 5290009 then 30 
			when DA.S_S = 5290010 then 40
			when DA.S_S = 5290011 then 50
		end as AUTHTYPE,
		'approver' as REMARK
	
	from 
		dbo.DA_CONCESSION DA with(nolock)
	where 
		DA.ID = @DocID

    /* Get deputies of previously finded user */	
	insert into @UsersIDs
	select 
		dbo.COM_USER_BY_EMPL(AED.EMPLID) USERID,
		AED.EMPLID EMPLID,
		null,
		'deputy'
	from DA_CONCESSION_APPROVE_EMPL AE
	inner join @UsersIDs U on AE.EMPLID =  U.EMPLID and AE.AUTHTYPE = U.AUTHTYPE
	left join DA_CONCESSION_APPROVE_EMPL_DEPUTY AED on AED.VNESHID = AE.ID

	
	/* Check if user CAN run method dependig doc state*/
	if(@UserID in (Select distinct UserID from @UsersIDs))
		set @res = 1 -- CAN approve/reject

	return @res
end