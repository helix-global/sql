create PROCEDURE [dbo].[MSG_PLANED_DATE_CHANGED_SEND] 
  @aUserID int, @aDeliveryType int, @aDepID int, @aSubj nvarchar(1024), @aBoby varchar(max), @aExcludeRecipientsFromDepart nvarchar(max)
AS
BEGIN
set nocount on  
  
  if not exists (select A.ID from MSG_DELIVERYLIST A with (nolock) where A.DELIVERYTYPE = @aDeliveryType and A.DEPID = @aDepID)
  begin
     set nocount off
     return
  end
  
  declare @vTo nvarchar(1024)
  declare @vToCopy nvarchar(1024)

  select @vTo = A.GREMAIL + '; '
  from MSG_DELIVERYLIST A
  where A.DELIVERYTYPE = @aDeliveryType 
    and A.DEPID = @aDepID
    and A.GREMAIL is not null

  select @vTo = isnull(@vTo,'') + C.EMAIL + '; '
  from MSG_DELIVERYLIST A
  left join MSG_DELIVERYLIST_T T with (nolock) on T.VNESHID = A.ID
  left join COM_EMPLOYEE C with (nolock) on C.ID = T.EMPLID
  where A.DELIVERYTYPE = @aDeliveryType 
    and A.DEPID = @aDepID
    and C.EMAIL is not null
    and isnull(T.EMPCOPY,0) = 0
    and (@aExcludeRecipientsFromDepart is null or C.DEPID not in (select ID from dbo.COM_STR2TABLE_INT(@aExcludeRecipientsFromDepart) where ID is not null))

  select @vToCopy = isnull(@vToCopy,'') + C.EMAIL + '; '
  from MSG_DELIVERYLIST A
  left join MSG_DELIVERYLIST_T T with (nolock) on T.VNESHID = A.ID
  left join COM_EMPLOYEE C with (nolock) on C.ID = T.EMPLID
  where A.DELIVERYTYPE = @aDeliveryType 
    and A.DEPID = @aDepID
    and C.EMAIL is not null
    and isnull(T.EMPCOPY,0) = 1
    and (@aExcludeRecipientsFromDepart is null or C.DEPID not in (select ID from dbo.COM_STR2TABLE_INT(@aExcludeRecipientsFromDepart) where ID is not null))

  
  if LEN(@vTo) > 1
  begin 
    insert into MSG_OUTGOING (S_S, GID, MSGTO, MSGCC, MSGSUBJ, MSGBODY, S_CDT, S_CR ) 
    values (1, NEWID(), @vTo , @vToCopy , @aSubj,  @aBoby, GETDATE(), @aUserID)
  end


set nocount off
END