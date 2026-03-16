CREATE function [dbo].[PR_MAP_DEP_ACCESS](@aMapID int,@aMode int,@aUser int,@aDate datetime)
returns int as 
begin
  declare @DepID int
  /*
  select @DepID = A.DEPARTMENTID from PR_MODELTYPE A with (nolock) 
   where A.ID = (select B.MTID from PR_MAP B with (nolock) where B.ID = @aMapID)
  */
  select @DepID = B.DEPID from PR_MAP B with (nolock) where B.ID = @aMapID
  
  declare @res int
  select @res = dbo.COM_DEP_ACCESS(null,@DepID,@aMode,@aUser,@aDate)
  
  if @res = 1
    return 1
  
  
  if @aMode = 8
  begin
    
    if dbo.DEF_USERINGROUP4(@aUser,'DES',@aDate) = 1
    begin
        
		if exists (select B.MAPID from PR_REVISION B with (nolock) 
		            where B.MODELID in (select C.MODELID from PR_MODEL_SHARINGR C with (nolock) 
		                                 where C.DEPARTMENTID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUser,8,@aDate))
		                                   and C.RULETYPE in (2,3)
		                                      )
		              and B.MAPID = @aMapID                        
		           )
		  return 1               
    end
  
  end  
  
  return @res
  
  
end