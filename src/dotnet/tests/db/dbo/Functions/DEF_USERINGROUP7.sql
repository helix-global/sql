CREATE function [dbo].[DEF_USERINGROUP7](@UserID int,@GroupName nvarchar(50))
returns int as 
begin
  declare @GroupID int
  select top 1
    @GroupID = [a].[ID]
  from [dbo].[DEF_USERS] [a] with(nolock)
  where [a].[LOGINNAME]=@GroupName
    and [a].[ISGROUP] in (1,2)

  if @GroupID is null return 0;
  return [dbo].[DEF_USERINGROUP3](@UserID,@GroupID)
end