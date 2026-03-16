-- TEST
-- exec [dbo].[PR_CHECK_OPEN_OPERATION] 82485293, 2950
CREATE procedure [dbo].[PR_CHECK_OPEN_OPERATION] @OperID int, @UserID int
as
begin
  set nocount on

  declare @completed datetime,
    @orderDepID int,
    @formDepID int,
    @operState int,
    @assignedUserID int,
    @prGroup int,
    @eqID int,
    @modelID int

  select
    @completed = operation.[COMPLETED_DT],
    @operState = operation.[S_S],
    @orderDepID = prOrder.[DEPARTMENTID],
    @formDepID = operationDict.[DEPID],
    @assignedUserID = operation.[USERINPROGRESS],
    @prGroup = operationDict.[OPERGRID],
    @eqID = operation.[EQID],
    @modelID = device.[MODELID]
  from
    [dbo].[PR_OPERATION] operation (nolock)
    left join [dbo].[PR_PRORDER] prOrder (nolock) on prOrder.[ID] = operation.[ORDERID]
    left join [dbo].[PR_OPERATIONS] operationDict (nolock) on operationDict.[ID] = operation.[OPERTYPEID]
    left join [dbo].[PR_DEVICE] device (nolock) on device.[ID] = operation.[DEVICEID]
  where
    operation.[ID] = @OperID

  if @completed is null
  begin
     set nocount off;
     return;
  end

  if @assignedUserID = @UserID
  begin
     set nocount off;
     return;
  end  

  declare @now datetime = getdate()

  if dbo.COM_DEP_ACCESS(null, isnull(@orderDepID, @formDepID), 1 /*Read*/, @UserID, @now) = 1
  begin
     set nocount off;
     return;
  end

  declare @emplID int, @emplDepID int;

  select @emplID = [EMPLOYEEID]
  from [dbo].[DEF_USERS] (nolock) 
  where [ID] = @UserID;

  select @emplDepID = [dbo].[COM_EMPLOYEE_DEP_BY_DATE](@emplID, @now);

  if exists (select Q.ID 
             from PR_EMPL_TO_OPERGR Q with (nolock)
            where Q.EMPLOYEEID = @emplID
              and Q.GROUPID = @prGroup 
              and ISNULL(Q.DBEG,'19900101') <= @now
              and ISNULL(Q.DEND,'40000101') >= @now
           )
  begin
     set nocount off;
     return;
  end

  if exists (select Q.ID 
             from PR_RESOURCE_PLAN_T Q with (nolock)
             left join PR_RESOURCE_PLAN K with (nolock) on K.ID = Q.VNESHID
            where Q.EMPID = @emplID
              and Q.OPERGRID = @prGroup 
              and Q.[ACTION] = 1
              and K.DEPID = @emplDepID
           )
  begin
     set nocount off;
     return;
  end

  if @eqID is not null 
  begin
    if dbo.DEF_CLASS_ACCESS(1000247,'eq_equipment',3/*view*/,@now,@UserID) = 1
    begin
      set nocount off;
      return;
    end
  end

  -- Azure#6238: "департамент, к которому относится пользователь, равен департаменту модели из запускаемой операции и на департамент заказа настроено Sharing Rules=Production.
  -- Соответственно тогда будем считать, что раз этот пользователь собственник модели и эта модель доступна для производства в другом департаменте, то он может открыть карточку операции"
  if @modelID is not null and @orderDepID is not null
  begin
    if exists
    (
      select top 1 1
      from [dbo].[PR_MODELS] models (nolock)
      join [dbo].[PR_MODEL_SHARINGR] modelSharing (nolock) on modelSharing.[MODELID] = models.[ID]
      where models.[ID] = @modelID and models.[DEPID] = @emplDepID and modelSharing.[DEPARTMENTID] = @orderDepID and modelSharing.[RULETYPE] = 1 /*Production*/
    )
    begin
      set nocount off;
      return;
    end
  end

  raiserror('#EYou are not authorized to open this document.[L=pr_open_operation_violation',16,1)
  
  set nocount off
end