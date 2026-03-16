-- KB5328:2025-03-27: Refactoring.
CREATE function [dbo].[COM_ACCESS_DEPARTMENTS] (@UserID int,@Mode int,@Date datetime)
returns @OutT table ([ID] int primary key clustered)
as
begin
  insert into @OutT ([ID])
    select [dep].[ID]
    from [dbo].[COM_DEPARTMENTS] [dep] with(nolock)
    where [dbo].[COM_DEP_ACCESS](null,[dep].[ID],@Mode,@UserID,@Date) = 1
      and isnull([dep].[DISABLED],0) <> 1

  if [dbo].[DEF_USERINGROUP4](@UserID,'LA',@Date) = 1
  begin
    merge @OutT [a]
    using
      (
      select [dep].[ID]
      from [COM_DEPARTMENTS] [dep] with(nolock)
      where isnull([dep].[DISABLED],0) <> 1
      ) [b] on [a].[ID]=[b].[ID]
    when not matched then
      insert ([ID]) values ([b].[ID]);
  end
  return
end