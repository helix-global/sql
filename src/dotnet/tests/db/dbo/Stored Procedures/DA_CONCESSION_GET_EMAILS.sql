
CREATE PROCEDURE [dbo].[DA_CONCESSION_GET_EMAILS]
	@ContextID int,
	@MailTo nvarchar(1024) OUT,
	@CopyTo nvarchar(1024) OUT
AS
BEGIN

/* DEVOPS_5097 / KB5514 */

--declare @ContextID int = 33 --20

/* Get email depending state of documnet */
/* Return 2 list of emails - SentTo and CopyTo */

--Codes for approve employee type
--Code	Name
--10	Issued
--20	Checked
--30	QM
--40	PLM
--50	MD

declare @EmailToEmployee table (EMPLID int);
declare @CopyToEmployee table (EMPLID int);
declare @DocState int;

declare @Created int;
declare @Issued int;
declare @CheckedQM int;
declare @ReleasedPLM int;
declare @ApprovedMD int;

/* fill variables from doc by context */
select 
	@DocState = C.S_S,
	@Created = C.S_CR,
	@Issued = C.ISSUEDID,
	@CheckedQM = C.CHECKEDID,
	@ReleasedPLM = C.RELEASEDID,
	@ApprovedMD = C.APPROVEDID
from 
	dbo.DA_CONCESSION C with (nolock)
where C.ID = @ContextID


/* need "checked" approve (Waiting for approval) */
if(@DocState = 5290008)
begin 
	-- mail to 
	insert into @EmailToEmployee (EMPLID)
	select 
		CC.EMPLID 
	from 
		dbo.DA_CONCESSION_CHECKED CC with (nolock)
	where 
		CC.VNESHID = @ContextID

	-- copy to
	insert into @CopyToEmployee (EMPLID)
	select 
		CAED.EMPLID
	from 
		dbo.DA_CONCESSION_APPROVE_EMPL CAE with (nolock)
		left join 
		dbo.DA_CONCESSION_APPROVE_EMPL_DEPUTY CAED with (nolock) on CAED.VNESHID = CAE.ID
	where
		CAE.AUTHTYPE = 20 --Checked
		and 
		CAE.EMPLID in (select * from @EmailToEmployee)
		and 
		CAED.ID is not null
end

/* need "QM" approve (Waiting for QM approval) */
else if(@DocState = 5290009)
begin
	-- mail to
	insert into @EmailToEmployee (EMPLID)
	select @CheckedQM

	-- copy to
	insert into @CopyToEmployee (EMPLID)
	select 
		CAED.EMPLID
	from 
		dbo.DA_CONCESSION_APPROVE_EMPL CAE with (nolock)
		left join 
		dbo.DA_CONCESSION_APPROVE_EMPL_DEPUTY CAED with (nolock) on CAED.VNESHID = CAE.ID
	where
		CAE.AUTHTYPE = 30 --QM
		and 
		CAE.EMPLID in (select * from @EmailToEmployee)
		and 
		CAED.ID is not null
end

/* need "PLM" approve (Waiting for PLM approval) */
else if(@DocState = 5290010)
begin
	-- mail to
	insert into @EmailToEmployee (EMPLID)
	select @ReleasedPLM

	-- copy to
	insert into @CopyToEmployee (EMPLID)
	select 
		CAED.EMPLID
	from 
		dbo.DA_CONCESSION_APPROVE_EMPL CAE with (nolock)
		left join 
		dbo.DA_CONCESSION_APPROVE_EMPL_DEPUTY CAED with (nolock) on CAED.VNESHID = CAE.ID
	where
		CAE.AUTHTYPE = 40 --PLM
		and 
		CAE.EMPLID in (select * from @EmailToEmployee)
		and 
		CAED.ID is not null
end

/* need "MD" approve (Waiting for MD approval) */
else if(@DocState = 5290011)
begin
	-- mail to
	insert into @EmailToEmployee (EMPLID)
	select @ApprovedMD

	-- copy to
	insert into @CopyToEmployee (EMPLID)
	select 
		CAED.EMPLID
	from 
		dbo.DA_CONCESSION_APPROVE_EMPL CAE with (nolock)
		left join 
		dbo.DA_CONCESSION_APPROVE_EMPL_DEPUTY CAED with (nolock) on CAED.VNESHID = CAE.ID
	where
		CAE.AUTHTYPE = 50 --PLM
		and 
		CAE.EMPLID in (select * from @EmailToEmployee)
		and 
		CAED.ID is not null
end

/* to all if Approved  or "Rejected"*/
else if(@DocState = 5290013 or @DocState = 5290012)
begin
	-- mail to CHECKED
	insert into @EmailToEmployee (EMPLID)
	select 
		CC.EMPLID 
	from 
		dbo.DA_CONCESSION_CHECKED CC with (nolock)
	where 
		CC.VNESHID = @ContextID
	--mail to Issued
	insert into @EmailToEmployee (EMPLID)
	select @Issued
	-- mail to QM
	insert into @EmailToEmployee (EMPLID)
	select @CheckedQM
	-- mail to PLM
	insert into @EmailToEmployee (EMPLID)
	select @ReleasedPLM
	-- mail to MD
	insert into @EmailToEmployee (EMPLID)
	select @ReleasedPLM

	/* DEVOPS:6111 - remove
	-- copy to (all marked as Notify from "deputy")
	insert into @CopyToEmployee (EMPLID)
	select 
		CAED.EMPLID
	from 
		dbo.DA_CONCESSION_APPROVE_EMPL CAE with (nolock)
		left join 
		dbo.DA_CONCESSION_APPROVE_EMPL_DEPUTY CAED with (nolock) on CAED.VNESHID = CAE.ID
	where
		CAE.EMPLID in (select * from @EmailToEmployee)
		and 
		CAED.ID is not null	 
		and
		isnull(CAED.NOTIFY,0) =1
	*/

	/* Get all employees mantionde in Notified tab  DEVOPS:6111 */
	insert into @CopyToEmployee (EMPLID)
	select EMPLID
	from DA_CONCESSION_FINAL_NOTIFY CN with (nolock)
	where VNESHID = @ContextID

	 -- copy to all deputy employee who sign document on behalf
	 insert into @CopyToEmployee
	 select ID from [dbo].[DA_CONCESSION_GET_SIGNED_ON_BEHALF](@ContextID)
end


/* author "Created" */
else if(@DocState = 1  or @DocState = 5290015 /* Restarted */ )
begin
	-- mail to Creator
	insert into @EmailToEmployee (EMPLID)
	select top 1 U.EMPLOYEEID from dbo.DEF_USERS U with (nolock) where U.ID = @Created

	/* DEVOPS:6157 move to Approved section */
	--if Rejected also send to employees mantionde in Notified tab  DEVOPS:6111 
	--if (@DocState = 5290012) /* Rejected */
	--begin 
	--	/* Get all employees mantionde in Notified tab  DEVOPS:6111 */
	--	insert into @CopyToEmployee (EMPLID)
	--	select EMPLID
	--	from DA_CONCESSION_FINAL_NOTIFY CN with (nolock)
	--	where VNESHID = @ContextID
	--end

end

--test check 
--select * from @EmailToEmployee
--select * from @CopyToEmployee

/* prepear list of emails */
--normilze table - remove NULL and double records
;WITH cte AS (
    SELECT 
        EMPLID,
        ROW_NUMBER() OVER (PARTITION BY EMPLID ORDER BY (SELECT NULL)) AS rn
    FROM @EmailToEmployee
)
DELETE FROM cte WHERE rn > 1 or EMPLID is null;

--normilze table - remove NULL and double records and records already in @EmailToEmployee table
;WITH cte AS (
    SELECT 
        EMPLID,
        ROW_NUMBER() OVER (PARTITION BY EMPLID ORDER BY (SELECT NULL)) AS rn
    FROM @CopyToEmployee
)
DELETE FROM cte WHERE rn > 1 or EMPLID is null or EMPLID in (select EMPLID from @EmailToEmployee);

set @MailTo = isnull(
	(select dbo.GROUP_CONCAT(EMAIL) 
	from COM_EMPLOYEE 
	where ID in (select EMPLID from @EmailToEmployee)
	and EMAIL is not null), '')

set @CopyTo = isnull(
	(select dbo.GROUP_CONCAT(EMAIL) 
	from COM_EMPLOYEE 
	where ID in (select EMPLID from @CopyToEmployee)
	and EMAIL is not null), '')
END