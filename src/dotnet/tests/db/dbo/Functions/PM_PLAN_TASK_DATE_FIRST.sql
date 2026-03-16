

CREATE FUNCTION dbo.PM_PLAN_TASK_DATE_FIRST (@planID int)
returns date with schemabinding as

begin
	/* KB4189 */
	declare @res date

	-- вычисление мин даты из задач по плану для упоминании в теле письма
	select 
		--PT.VNESHID as PM_DEV_PLAN_ID, 
		@res = MIN(PTT.DD)
		
	from 
		dbo.PM_DEV_PLAN_T PT with (nolock)
		join dbo.PM_DEV_PLAN_T_T PTT with (nolock) on PTT.VNESHID = PT.ID
	where 
		PT.VNESHID = @planID
	group by 
		PT.VNESHID

	return @res
end