CREATE function [dbo].[COM_VACATIONS_CURRENT] (@aUserID int)
returns @res table (ID int)
as 
begin

  declare @dBeg date = getdate()

  insert into @res(ID)
  select A.ID
  from COM_VACATION A with (nolock)
  where isnull(A.DEND,A.DBEG) >= @dBeg 
    /*and dbo.COM_VACATION_ACCESS2(A.S_CR,A.S_S,A.EMPLID,@aUserID,0,getdate())=1 */
    and dbo.COM_VACATION_ACCESS3(A.S_CR,A.S_S,A.EMPLID,@aUserID,11,getdate())=1

return

end