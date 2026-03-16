CREATE function [dbo].[FC_FARA_SETTING](@FRid int, @UserID int)
returns int
as
begin

declare @depID int
declare @mtID int
declare @emplID int

select top 1 @emplID = A.EMPLOYEEID 
from DEF_USERS A with (nolock) 
where A.ID = @UserID

select @depID = B.DEPID
      ,@mtID = B.TYPEID
from FC_REPORT A with (nolock)
left join PR_MODELS B with (nolock) on B.ID = A.MODELID
where A.ID = @FRid

if exists (select H.ID 
             from FC_FARA_SETTINGS H with (nolock) 
            where H.EMPLID = @emplID
              and H.DEPID in (select ID from dbo.COM_GETPARENT_DEPARTMENTS(@depID,1))
              and (H.MTID is null or H.MTID = @mtID)
              and H.FARAVIEW = 1
           )
begin
  
    
    if dbo.COM_DEP_ACCESS2(@depID, 1 , @UserID, getdate()) = 0  /* нет стандартного доступа */
    begin
      
      return 1
      
    end


end              
  
return 0  

end;