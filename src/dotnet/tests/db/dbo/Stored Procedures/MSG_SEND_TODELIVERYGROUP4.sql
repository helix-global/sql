/****** Object:  StoredProcedure [dbo].[MSG_SEND_TODELIVERYGROUP2]    Script Date: 05/23/2023 10:22:55 ******/
create PROCEDURE [dbo].[MSG_SEND_TODELIVERYGROUP4] 
  @aUserID int, @aDeliveryType int, @aDepID int, @aSubj nvarchar(1024), @aBoby nvarchar(max), @aImportance int
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

  select @vToCopy = isnull(@vToCopy,'') + C.EMAIL + '; '
  from MSG_DELIVERYLIST A
  left join MSG_DELIVERYLIST_T T with (nolock) on T.VNESHID = A.ID
  left join COM_EMPLOYEE C with (nolock) on C.ID = T.EMPLID
  where A.DELIVERYTYPE = @aDeliveryType 
    and A.DEPID = @aDepID
    and C.EMAIL is not null
    and isnull(T.EMPCOPY,0) = 1

  
  if LEN(@vTo) > 1
  begin 
    insert into MSG_OUTGOING (S_S, GID, MSGTO, MSGCC, MSGSUBJ, MSGBODY, S_CDT, S_CR, MSGIMP) 
    values (1, NEWID(), @vTo , @vToCopy , @aSubj,  @aBoby, GETDATE(), @aUserID, @aImportance)
  end


set nocount off
END