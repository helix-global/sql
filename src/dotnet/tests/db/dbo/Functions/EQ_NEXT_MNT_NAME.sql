create function [dbo].[EQ_NEXT_MNT_NAME](@aEqID int, @aMode int)
returns nvarchar(100) as 
begin

   declare @res nvarchar(100)
   
   select top 1 @res = OP.NAME
   from MNT_PLAN_EQ GA with (nolock) 
   left join MNT_PLAN GB with (nolock) on GB.ID = GA.VNESHID 
   left join PR_OPERATIONS OP with (nolock) on OP.ID = GB.OPERID
   where GA.EQID = @aEqID 
     and GB.S_S = 1 
     and GB.CRMODE in (3,4)
   order by GA.NEXTDATE
   
   return @res 

end