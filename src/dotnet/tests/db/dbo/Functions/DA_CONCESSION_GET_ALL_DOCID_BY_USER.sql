

CREATE FUNCTION DA_CONCESSION_GET_ALL_DOCID_BY_USER(@UserID int)
returns @res table (ID int)
as 
begin
	/* GET ALL documnets where user is presented like approver or deputy */
	/* Возвращает все документы где пользователь участвует как один из удверждающих или как зам одного из утверждающих */
	
	--test
	--declare @UserID int = 26052
	
	declare @AllDocApprovers table (ID int, EMPLID int, APP_TYPE VARCHAR(3))
	
	/* All MAIN approvers */
	insert into @AllDocApprovers
	SELECT 
		DISTINCT t.ID, v.EMPLID, 'M'
	FROM dbo.DA_CONCESSION AS t
	CROSS APPLY (VALUES
	    (t.ISSUEDID),
	    (t.CHECKEDID),
	    (t.RELEASEDID),
	    (t.APPROVEDID)
	) AS v(EMPLID)
	WHERE 
		v.EMPLID IS NOT NULL;
	
	/* All CHECKED approvers */
	insert into @AllDocApprovers
	select 
		 C.VNESHID as ID,
		 C.EMPLID,
		 'C'
	from 
		dbo.DA_CONCESSION_CHECKED C with (nolock)
		left join @AllDocApprovers A on A.ID = C.VNESHID and A.EMPLID = C.EMPLID
	where 
		A.ID is null
	
	/* All DEPUTY of all previous approvers */
	insert into @AllDocApprovers
	select 
		A.ID as ID,
		--AE.EMPLID ,
		D.EMPLID as EMPLID,  /* DEPUTY EMPLID */
		'D'
	from 
		dbo.DA_CONCESSION_APPROVE_EMPL_DEPUTY D with (nolock)
		left join dbo.DA_CONCESSION_APPROVE_EMPL AE with (nolock) on D.VNESHID = AE.ID
		left join @AllDocApprovers A on A.EMPLID = AE.EMPLID
		left join @AllDocApprovers AA on AA.ID = A.ID and AA.EMPLID = D.EMPLID
	where 
		AA.ID is null


	/* All DOCS where user is presented as Main Approver, Checked Approver or as one of the Deputy */
	insert into @res
	select 
		DISTINCT ID 
	from 
		@AllDocApprovers
	where 
		dbo.COM_USER_BY_EMPL(EMPLID) = @UserID


	return

end