CREATE function [dbo].[PR_STAGES_ACCESS_TAB](@aUser int,@aMode int,@aDate datetime)
returns @res table (ID int) as 
begin
  
  declare @deps table (ID int)
  
  insert into @deps (ID)
  select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUser,@aMode,@aDate)
  
  insert into @res 
  select A.ID
    from PR_STAGES A with (nolock) 
   where A.DEPID in (select ID from @deps)

  if @aMode = 8
  begin
    
    if dbo.DEF_USERINGROUP4(@aUser,'DES',@aDate) = 1
    begin
      
      insert into @res 
      select A.ID
        from PR_STAGES A with (nolock) 
       where A.MTID in  (select B.TYPEID
                           from PR_MODEL_SHARINGR C with (nolock) 
                           left join PR_MODELS B with (nolock) on B.ID = C.MODELID
		                  where C.DEPARTMENTID in (select ID from @deps)
		                    and C.RULETYPE in (2,3)
		                 )
      
    end
  
  end      
  
  return 
end