create function [dbo].[PR_REVISIONS_BY_MODELGROUPS] (@ModelGrIDs nvarchar(max))
returns @res table (ID int)
as 
begin

insert into @res (ID) 
select JJ.ID 
	from PR_REVISION JJ with(nolock) 
	where JJ.MODELGROUPID in (select ID from dbo.COM_STR2TABLE_INT(@ModelGrIDs))
union select KK.ID
	from PR_REVISION KK with(nolock) 
	left join PR_MODELS KL with(nolock) on KL.ID = KK.MODELID
where KL.MODELGROUPID in (select ID from dbo.COM_STR2TABLE_INT(@ModelGrIDs))


return

end