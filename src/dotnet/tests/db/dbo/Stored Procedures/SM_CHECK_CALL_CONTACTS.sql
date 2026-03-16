create PROCEDURE [dbo].[SM_CHECK_CALL_CONTACTS] @sCallID int, @UserID int, @aMode int
AS
BEGIN
  set nocount on
  
  /* 
     KB219 Реализовать механизм, который будет удалять контакт из поля 'Internal Contacts', если он присутствует в поле 'Contacts' для документа Service Call.
     Такая проверка нужна, если некое лицо присутствует и в справочнике Contacts и в справочнике Corporate Address Book, например сотрудник аффилированного подразделения. 
  */

  delete from SM_SERVICE_CALL_TINT 
  where VNESHID = @sCallID
    and exists (select B.ID 
                  from SM_SERVICE_CALL_T A with (nolock)
                  left join COM_CUST_CONTACTS B with (nolock) on B.ID = A.CNTID
                 where A.VNESHID = SM_SERVICE_CALL_TINT.VNESHID
                   and upper(B.EMAIL) = upper(SM_SERVICE_CALL_TINT.EMAIL)
                 )
  

    
  set nocount off
END