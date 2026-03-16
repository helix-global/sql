CREATE function [dbo].[LDM_WORKSPACE_ITEM_VISIBLE](@aOperationSett nvarchar(50), @aUserID int)
returns int as 
begin
  
  /* по коду настройки определяет группы операций и возращает 1 если пользователь привязан к этой операции */
  /* TODO не учитываются планы */
  
  declare @emplID int
  select @emplID = A.EMPLOYEEID from DEF_USERS A with (nolock) where A.ID = @aUserID
  
  declare @now datetime = getdate()
  
  if exists (
		  select F.ID 
		   from PR_EMPL_TO_OPERGR F with (nolock) 
		   where F.EMPLOYEEID = @emplID 
			 and isnull(F.DBEG,'19900101') <= @now
			 and isnull(F.DEND,'40000101') >= @now
			 and F.GROUPID in (select B.VALUEINT from LDM_SETTINGS B with (nolock) where B.LABEL = @aOperationSett)
            )
            return 1
  
     
  return 0

end