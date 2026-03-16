CREATE function [dbo].[PR_REVISION_DEP_ACCESS_TAB](@aUser int,@aMode int,@aDate datetime)
returns @res table (ID int) as 
begin
  
  declare @deps table (ID int)
  
  insert into @deps (ID)
  select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUser,@aMode,@aDate)
  
  insert into @res 
  select A.ID
  from PR_REVISION A with (nolock)
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID
  where B.DEPID in (select ID from @deps )
  

  if @aMode = 8
  begin
    
    if dbo.DEF_USERINGROUP4(@aUser,'DES',@aDate) = 1
    begin
		insert into @res (ID)
		select B.ID from PR_REVISION B with (nolock) 
		 where B.MODELID in (select C.MODELID from PR_MODEL_SHARINGR C with (nolock) 
		                      where C.DEPARTMENTID in (select ID from @deps)
		                        and C.RULETYPE in (2,3)
  		                    ) 
    end
    
    /* 30.01.19 для KB436 добавка от действия 2000017 в классе pr_model_types*/
    insert into @res (ID)
	select B.ID 
	from PR_REVISION B with (nolock) 
	left join PR_MODELS C with (nolock) on C.ID = B.MODELID
	left join PR_MODELTYPE D with (nolock) on D.ID = C.TYPEID
	where dbo.DEF_F_ACCESS(D.ARC,null,2000017,@aDate,@aUser,0) = 1
  
  end      
  
  return 
end