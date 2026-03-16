CREATE function [dbo].[PR_REPORTS_ACCESS_TAB](@aUser int,@aMode int,@aDate datetime)
returns @res table (ID int) as 
begin
  
  declare @deps table (ID int)
  
  insert into @deps (ID)
  select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUser,@aMode,@aDate)
  
  insert into @res 
  select A.ID
  from PR_REPORTS A with (nolock)
  where A.DEPID in (select ID from @deps )
  

  if @aMode = 8
  begin
    
    if dbo.DEF_USERINGROUP4(@aUser,'DES',@aDate) = 1
    begin
        declare @mdls table (ID int, MTID int, DEPID int)
        insert into @mdls (ID, MTID, DEPID)
        select C.MODELID, N.TYPEID , N.DEPID
        from PR_MODEL_SHARINGR C with (nolock) 
        left join PR_MODELS N with (nolock) on N.ID = C.MODELID
		where C.DEPARTMENTID in (select ID from @deps)
		  and C.RULETYPE in (2,3)
    
		insert into @res (ID)
		select B.VNESHID 
		from PR_REPORTS_T B with (nolock) 
		left join PR_REPORTS A with (nolock) on A.ID = B.VNESHID
		 where B.MODELID in (select ID from @mdls)
		   /*and A.DEPID in (select DEPID from @mdls )*/

		insert into @res (ID)
		select B.VNESHID from PR_REPORTS_T B with (nolock) 
		 left join PR_REPORTS A with (nolock) on A.ID = B.VNESHID
		 where B.REVID in (select A.ID from PR_REVISION A with (nolock) where A.MODELID in (select ID from @mdls))
		   and A.DEPID in (select DEPID from @mdls )

		insert into @res (ID)
		select A.ID from
        (select A.ID, A.MTID from PR_REPORTS A with (nolock) 
         where A.DEPID in (select DEPID from @mdls )
           and not exists (select B.ID from PR_REPORTS_T B with (nolock) where B.VNESHID = A.ID)) A
          where A.MTID in (select MTID from @mdls)
		 
    --    insert into @res (ID)
    --    select distinct A.ID from PR_REPORTS A with (nolock) 
				--join @mdls M on A.DEPID=M.DEPID 
				--join @mdls M2 on A.MTID=M2.MTID
    --     where /*A.DEPID in (select DEPID from @mdls )
    --       and A.MTID in (select MTID from @mdls)
    --       and */not exists (select B.ID from PR_REPORTS_T B with (nolock) where B.VNESHID = A.ID)
    end
    
    insert into @res (ID)
    select A.ID
    from PR_REPORTS A with (nolock) 
    left join PR_MODELTYPE C with (nolock) on C.ID = A.MTID
    where dbo.DEF_F_ACCESS2(C.ARC,null,2000017/*designer*/,@aDate,@aUser,0) = 1

  
  end      
  
  return 
end