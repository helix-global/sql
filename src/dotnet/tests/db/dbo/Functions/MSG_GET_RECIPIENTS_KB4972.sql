




CREATE FUNCTION dbo.[MSG_GET_RECIPIENTS_KB4972]
(
	@USERID int, @MID int, @CHTYPE int
)
RETURNS nvarchar(1024)
AS
BEGIN

/* KB4972: get all recipient mails by modelID and type of nitification*/

/* @CHTYPE
5 New model created
6 Model approved
7 Model files changed
*/

/* FOR TEST
--select * from PR_MODELS where TYPEID = 683
--declare @MID int = 30760 -- 35350 --30760 -- model ID 35350
--declare @CHTYPE int = 6 -- change type
*/

declare @MTID int;
---declare @MNAME varchar(1024);
--declare @MTNAME varchar(1024);

declare @MSGTO varchar(1024) = null

/* fill additional model info */
select top 1 
	 @MTID = M.TYPEID		-- get modeltype ID by modelID
	--,@MTNAME = MT.NAME		-- get modeltype NAME by modelID (for use in email)
	--,@MNAME = M.NAME		-- model name for use in email
from 
	dbo.PR_MODELS M with (nolock)
	left join dbo.PR_MODELTYPE MT with(nolock) on M.TYPEID = MT.ID
where 
	M.ID = @MID  

/* get uniq emails from setting with model/modeltype from tab "Notifiacation Employee" from pr_mt_change_notify doc */
select 
	@MSGTO = dbo.GROUP_CONCAT(DISTINCT EE.EMAIL) 
	/* if in future needed field MSGTO...
	+ isnull(',' +dbo.GROUP_CONCAT(N.MSGTO), '')
	*/
from 
	PR_MT_CHANGE_NOTIFY N with (nolock)
	join dbo.PR_MT_CHANGE_NOTIFY_EMPL E with (nolock) on N.ID = E.VNESHID
	left join dbo.COM_EMPLOYEE EE with (nolock) on EE.ID = E.EMPLID
	left join dbo.PR_MODELS M with (nolock) on M.ID = @MID
where 
	N.CHTYPE = @CHTYPE and											-- required change type
	N.MTID = @MTID and												-- required model type
	(N.MID = @MID or isnull(MID,0) = 0)								-- required exact model or "for all model" (if not set)
	and (M.PRTYPE = 1 /* Standard Product */ or @CHTYPE <> 5)		-- if "New model created" than only for product type like "Standard Product"

	return @MSGTO

END