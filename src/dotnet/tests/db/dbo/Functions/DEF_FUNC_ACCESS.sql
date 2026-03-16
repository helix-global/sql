create function [dbo].[DEF_FUNC_ACCESS](@aARC int, @aAction int , @aFuncGroup nvarchar(200),@aDate datetime)
returns int as 
begin

  declare @tmp int = null;
    
  select @tmp = MAX(A.RES) 
   from DEF_ACCESS A  with (nolock)  
   left join DEF_USERS B with (nolock) on B.ID = A.UID and B.ISGROUP = 3 
   where B.LOGINNAME = @aFuncGroup 
     and A.ARC = @aARC and A.ACT in (1,10,100,@aAction);

  if (@tmp = 1) return 1 
    

  return 0;
end