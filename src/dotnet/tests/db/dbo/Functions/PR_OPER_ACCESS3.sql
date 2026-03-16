-- KB5383:2025-04-22: Initial Update.
CREATE function [dbo].[PR_OPER_ACCESS3](@UserID int,@OperGrID int,@OrderDepID int,@ModelTypeDepID int,@ModelID int,@Date datetime)
returns int as
begin
  declare @DepID int
  set @DepID = @OrderDepID
  if @DepID is null /* для подготовительных операций (нет заказ) используется подразделение с типа модели*/
  begin
    set @DepID = @ModelTypeDepID
  end

  if exists (select [a].[LINKID]
             from [dbo].[PR_OPERGROUPS_RAW_BYUSER] [a] with(nolock,noexpand)
             where [a].[USERID] = @UserID
               and [a].[DEPID] = @DepID
               and [a].[GROUPID] = @OperGrID
               and [a].[DBEG] < @Date
               and [a].[DEND] > @Date
             )
  begin
    return 1
  end

  if [dbo].[COM_DEP_ACCESS](null,@DepID,1,@UserID,@Date) = 1
  begin
    return 1
  end
  if [dbo].[PR_MODELS_CAN_PRODUCE_MODEL](@UserID,@ModelID)=1
  begin
    return 1
  end
  return 0
end