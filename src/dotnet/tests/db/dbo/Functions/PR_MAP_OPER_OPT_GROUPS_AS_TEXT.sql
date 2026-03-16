CREATE FUNCTION [dbo].[PR_MAP_OPER_OPT_GROUPS_AS_TEXT]
(
	@mapoperid int
)
RETURNS varchar(max)
AS
BEGIN
	declare @res varchar(max) = ''
	
	select @res = @res + GR.NAME + ', '
	from dbo.PR_MAP_OPER_OPT_GROUPS GRPS 
	left join PR_MODELTYPE_OPTION_GR GR with (nolock) on GRPS.OPT_MDL_GRP_ID = GR.ID
	where MAPOPERID = @mapoperid
	order by GR.ID

	if(@res<>'')
	begin
		set @res = substring(@res, 1, len(@res)-1)
	end
	
	
	return @res


END