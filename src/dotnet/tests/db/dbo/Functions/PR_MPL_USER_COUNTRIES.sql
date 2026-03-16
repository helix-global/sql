
--KB5224: Refactoring
CREATE function [dbo].[PR_MPL_USER_COUNTRIES](@UserID int)
returns @OutT table ([ID] int primary key clustered)
as
begin
  insert into @OutT
    select distinct [a].[COUNTRYID]
    from [dbo].[PR_MPL_GROUP_ACCESSS_T] [a] with(nolock)
      inner join [dbo].[PR_MPL_GROUP_ACCESSS] [b] with(nolock) on [b].[ID]=[a].[GROUPID]
    where [dbo].[DEF_USERINGROUP](@UserID,[b].[MPL_GROUPID],getdate())=1
  return
end