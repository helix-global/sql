

CREATE FUNCTION dbo.PM_PLAN_TASK_DATE_OVERDUE (@planID int)
returns int with schemabinding as

begin
	/* KB4189 */
	declare @res int = null

	select 
		@res = 1
	from 
		dbo.PM_DEV_PLAN P with (nolock)
	where 
		P.S_S <> 2130059 /* не Deprecated */
		and 
		P.ID = @planID
		and dbo.PM_PLAN_TASK_DATE_LAST(P.ID) < GETDATE()
	
	return @res

end