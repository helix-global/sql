create function [dbo].[PR_MT2_ED_PARAMS](@MTID int, @UserID int,@OnDate datetime)  
 returns @res table(ID INT)
as 
begin  

   insert into @res(ID)
   select A.ID 
   from PR_MODELTYPE_PARAMS A
   left join PR_MODELTYPE_PARAMS_GR B on B.ID = A.PGROUP
   where A.TYPEID = @MTID
     and dbo.COM_DEP_ACCESS2(B.DEPID,5,@UserID,@OnDate) = 1
   
      
   return

end