CREATE function [dbo].[PR_IMP_FIND_BYPARAMSTR2](@aParamID int,@aLot nvarchar(200))  
 returns @res table(ID INT)
as 
begin  
  
  if exists (select A.ID from PR_IMP_INDEX_PRMS A with (nolock) where A.PRMID = @aParamID)
  begin
  
    insert into @res (ID)
	 select A.DEVICEID 
	 from PR_DEVICE_IN_VALUES AS A WITH (nolock)
	 where A.PARAMID = @aParamID
   	   and INDEX_STR like @aLot
  
	  insert into @res (ID)
	  select B.DEVICEID
	  from PR_OPERATION_PARAMS A with (nolock)
	  left join PR_OPERATION B with (nolock) on B.ID = A.OPERID
	  where A.PARAMID = @aParamID
		and B.S_S in (1000013,1000019,1000116)
	    and A.INDEX_STR like @aLot
    
  end
  else
  begin  
	  insert into @res (ID)
	  select A.DEVICEID 
	  from PR_DEVICE_IN_VALUES AS A WITH (nolock)
	  where A.PARAMID = @aParamID
		and upper(CAST(PVALUE AS nvarchar(50))) like @aLot
	
	  insert into @res (ID)
	  select B.DEVICEID
	  from PR_OPERATION_PARAMS A with (nolock)
	  left join PR_OPERATION B with (nolock) on B.ID = A.OPERID
	  where A.PARAMID = @aParamID
		and B.S_S in (1000013,1000019,1000116)
	    and upper(CAST(A.PVALUE AS nvarchar(50))) like @aLot
	
	 	
  end
  
  return

end