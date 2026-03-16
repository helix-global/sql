CREATE function [dbo].[PR_MAPS_ACCESS_TAB](@aUser int,@aMode int,@aDate datetime)
returns @res table (ID int) as 
begin
  
  declare @deps table (ID int)
  
  insert into @deps (ID)
  select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUser,@aMode,@aDate)
  
  insert into @res 
  select A.ID
  from PR_MAP A with (nolock)
  where A.DEPID in (select ID from @deps )

  insert into @res 
  select A.ID
  from PR_MAP A with (nolock)
  where A.ID in (select F.MAPID from PR_SERVICE_MAP_RULES F with (nolock) where F.DEPID in (select ID from @deps ))
    and A.MAPTYPE = 1
  

  if @aMode = 8
  begin
    
    if dbo.DEF_USERINGROUP4(@aUser,'DES',@aDate) = 1
    begin
		insert into @res (ID)
		select B.MAPID from PR_REVISION B with (nolock) 
		 where B.MODELID in (select C.MODELID from PR_MODEL_SHARINGR C with (nolock) 
		                      where C.DEPARTMENTID in (select ID from @deps)
		                        and C.RULETYPE in (2,3)
  		                    ) 
  		               
  		/*KB466*/     
  		insert into @res (ID)
  		select A.ID 
  		  from PR_MAP A with (nolock)
  		  left join PR_MODELTYPE F with (nolock) on F.ID = A.MTID
  		 where F.ID in (select G.TYPEID
  		                  from PR_MODEL_SHARINGR C with (nolock) 
  		                  left join PR_MODELS G with (nolock) on G.ID = C.MODELID 
		                 where C.DEPARTMENTID in (select ID from @deps)
		                   and C.RULETYPE in (2,3)
  		                    )   
  		  and A.MAPTYPE = 1
  		
    end
    
    insert into @res (ID)
    select A.ID
    from PR_MAP A with (nolock) 
    left join PR_MODELTYPE C with (nolock) on C.ID = A.MTID
    where dbo.DEF_F_ACCESS2(C.ARC,null,2000017/*designer*/,@aDate,@aUser,0) = 1

  
  end      
  
  return 
end