create function [dbo].[COM_FOREIGN_DEPS] ()
returns @res table (ID int)
as 
begin
 
  declare @locationCode nvarchar(50)
  
  set @locationCode = dbo.DEF_SYS_CONST_STR('com_remotelocation_code',null)
 
  insert into @res (ID)
  select A.ID from COM_DEPARTMENTS A with (nolock)
  where A.ID not in (select B.ID from dbo.COM_GETREMOTE_DEPARTMENTS(@locationCode) B)
  
  return

end