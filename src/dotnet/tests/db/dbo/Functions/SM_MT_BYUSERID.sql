create function [dbo].[SM_MT_BYUSERID] (@aUserID int,@aMode int)
returns @res table (ID int)
as 
begin

  declare @userDepID int = dbo.COM_DEPARTMENT2(@aUserID) 

  insert into @res (ID) 
  select distinct ID from dbo.SM_MT_BYDEPID(@userDepID,@aMode)
  
  return

end