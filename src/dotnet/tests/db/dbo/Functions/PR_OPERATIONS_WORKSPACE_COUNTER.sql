CREATE function [dbo].[PR_OPERATIONS_WORKSPACE_COUNTER](@UserID int,@aMode int)
returns int as 
begin

   declare @res int
   
   if (@aMode = 1) /* старый алгоритм подсчета ошибочных операций*/
   begin
   
      select @res = count(A.ID)
		from PR_OPERATION A with (nolock)
		left join PR_DEVICE B with (nolock) on B.ID = A.DEVICEID
		where A.S_S = 1000018 
		  and dbo.PR_OPER_DEP_ACCESS(A.ID,1,@UserID,getdate()) = 1
		  and B.S_S not in (1000100/*postp*/,1000069/*postp*/)
   
      return @res
   
   end
   else if (@aMode = 2) /* новый алгоритм подсчета ошибочных операций*/
   begin
   
	select @res = count(A.ID)
	from PR_OPERATION A with (nolock)
	left join PR_DEVICE B with (nolock) on B.ID = A.DEVICEID
	left join PR_MODELS C with (nolock) on C.ID = B.MODELID
	where A.S_S = 1000018 
	  and (A.OPERTYPEID in (select ID from PR_OPER_QUALIFICATION_TAB(@UserID,GETDATE())) or C.DEPID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@UserID,1,getdate()))) 
	  and B.S_S not in (1000100/*postp*/,1000069/*postp*/)

    return @res
   
   end
   else if (@aMode = 11) /* старый алгоритм подсчета операций troubleshooting */
   begin
   
		select @res = count(*)
		from PR_OPERATION A with (nolock)
		left join PR_OPERATIONS T1000242 with (nolock) on T1000242.ID = A.OPERTYPEID
		left join PR_OPERATIONS_GR GG with (nolock) on GG.ID = T1000242.OPERGRID
		where A.S_S = 1000032 
		  and dbo.COM_DEP_ACCESS2(GG.DEPARTMENTID,1,@UserID,getdate()) = 1
		  and T1000242.OPERTYPE = 1   
		  
        return @res
   
   end
   else if (@aMode = 12) /* новый алгоритм подсчета операций troubleshooting */
   begin
		declare @t table (OPERGRID int, D1 int,D2 int)
   
        insert into @t (OPERGRID, D1, D2)
        select T1000242.OPERGRID,T1000240.DEPARTMENTID,T1000341.DEPARTMENTID
		from PR_OPERATION A with (nolock) 
		left join PR_PRORDER T1000240 with (nolock) on T1000240.ID = A.ORDERID
		left join PR_OPERATIONS T1000242 with (nolock) on T1000242.ID = A.OPERTYPEID
		left join PR_OPERATIONS_GR T1000341 with (nolock) on T1000341.ID = T1000242.OPERGRID
		 where T1000341.DEPARTMENTID in (select ID from dbo.COM_ACCESS_DEPARTMENTS2(@UserID,1,getdate()))
		   and A.S_S = 1000032 
		   and T1000242.OPERTYPE = 1
		   
		 select @res = count(*)
		 from @t
		 where dbo.PR_OPER_ACCESS2(@UserID,OPERGRID,D1,D2,getdate()) = 1 
		   
         /*KB3583*/	
	 	 /*
		 from PR_OPERATION A with (nolock)
		 left join PR_OPERATIONS T1000242 with (nolock) on T1000242.ID = A.OPERTYPEID
		 left join PR_OPERATIONS_GR GG with (nolock) on GG.ID = T1000242.OPERGRID
		 where A.S_S = 1000032 
		   and GG.DEPARTMENTID in (select ID from dbo.COM_ACCESS_DEPARTMENTS2(@UserID,1,getdate()))
		   and T1000242.OPERTYPE = 1   
		  */
		  
        return @res
   
   end
   
   
   return null
  
end