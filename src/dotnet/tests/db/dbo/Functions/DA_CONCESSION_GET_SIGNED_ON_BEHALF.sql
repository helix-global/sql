



CREATE FUNCTION [dbo].[DA_CONCESSION_GET_SIGNED_ON_BEHALF](@ContextID int)
RETURNS 
@res TABLE 
(
	 ID int   
)
AS
BEGIN
	--test
	--declare @ContextID int = 57

	/* Get emails of deputy if deputy was signed doc insteaddocument approvers */
	/* DEVOPS_5097 / KB5514 */
	
	-- get main documnet deputy signed
	insert into @res
	SELECT distinct v.val
	FROM (
		select 
			case when DA.CHECKEDID = DA.REAL_CHECKEDID then null else DA.REAL_CHECKEDID end as CHECKEDID ,
			case when DA.RELEASEDID = DA.REAL_RELEASEDID then null else DA.REAL_RELEASEDID end as RELEASEDID,
			case when DA.APPROVEDID = DA.REAL_APPROVEDID then null else DA.REAL_APPROVEDID end as APPROVEDID
		from DA_CONCESSION DA with (nolock)
		where 
		DA.ID = @ContextID
	) AS s
	CROSS APPLY (VALUES (s.CHECKEDID), (s.RELEASEDID), (s.APPROVEDID)) AS v(val)
	WHERE v.val IS NOT NULL;
	
	-- get "checked" deputy signed
	insert into @res
	select 
		distinct 
		DA.REAL_APPROVEDID
		as val
	from 
		DA_CONCESSION_CHECKED DA with (nolock)
		left join @res D on D.ID <> DA.EMPLID
	where 
		DA.VNESHID = @ContextID and
		DA.EMPLID <> DA.REAL_APPROVEDID
	
	-- retrun deputy who was approve documnet instead of regular document approvers
	return

END