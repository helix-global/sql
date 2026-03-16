-- KB5383:2025-04-22: Refactoring.
CREATE function [dbo].[PR_OPER_DEP_ACCESS2](@OperID int,@OperTypeID int,@DepID int,@Mode int,@UserID int,@Date datetime)
returns int as
begin
  if [dbo].[PR_OPERTYPE_QUALIFICATION](@OperTypeID,@UserID,getdate()) = 1
  begin
    return 1
  end

  declare @r int
  select @r = [dbo].[COM_DEP_ACCESS](null,@DepID,@Mode,@UserID,@Date)
  return @r
end