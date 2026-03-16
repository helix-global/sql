CREATE function dbo.EQ_LAST_MNT_OPER_DATE(@aEqID int)
returns datetime as 
begin

   declare @res datetime
   
   select top(1) @res = GG.COMPLETED_DT 
   from PR_OPERATION GG with (nolock) 
   where GG.EQID = @aEqID 
   order by GG.COMPLETED_DT desc
      
   declare @res2 datetime
   
   select top(1) @res2 = GG.COMPLETED_DT 
   from PR_OPERATION_EQUIPMENT A with (nolock) 
   left join PR_OPERATION GG with (nolock) on GG.ID = A.OPERID
   where A.EQID = @aEqID
   order by GG.COMPLETED_DT desc
   
   if @res2 > @res or @res is null
     return @res2 
   
   return @res 

end