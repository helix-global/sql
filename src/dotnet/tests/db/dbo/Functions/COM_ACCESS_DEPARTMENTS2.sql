CREATE function [dbo].[COM_ACCESS_DEPARTMENTS2] (@aUserID int,@aMode int,@aDate datetime)
returns @res table (ID int)
as 
begin

insert into @res (ID) 
select A.ID from COM_DEPARTMENTS A with (nolock) 
where dbo.COM_DEP_ACCESS2(A.ID,@aMode,@aUserID,@aDate) = 1
  and isnull(A.DISABLED,0) <> 1 

return

end