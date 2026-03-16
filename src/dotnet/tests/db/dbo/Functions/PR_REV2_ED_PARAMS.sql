create function [dbo].[PR_REV2_ED_PARAMS](@RevID int, @UserID int,@OnDate datetime)  
 returns @res table(ID INT)
as 
begin  

   declare @mtid int
   
   select @mtid = B.TYPEID
   from PR_REVISION A 
   left join PR_MODELS B on B.ID = A.MODELID
   where A.ID = @RevID

   insert into @res(ID)
   select A.ID 
   from PR_MODELTYPE_PARAMS A
   left join PR_MODELTYPE_PARAMS_GR B on B.ID = A.PGROUP
   where A.TYPEID = @mtid
     and dbo.COM_DEP_ACCESS2(B.DEPID,5,@UserID,@OnDate) = 1
   
      
   return

end