CREATE function [dbo].[PR_IMP_FIND_BYPARAMSTR](@aParamID int,@aLot nvarchar(200))  
 returns @res table(ID INT)
as 
begin  
  
  if exists (select A.ID from PR_IMP_INDEX_PRMS A where A.PRMID = @aParamID)
  begin
  
    insert into @res (ID)
	 select A.DEVICEID 
	 from PR_DEVICE_IN_VALUES AS A WITH (nolock)
	 where A.PARAMID = @aParamID
   	   and INDEX_STR like @aLot
  
    
  end
  else
  begin  
	  insert into @res (ID)
	  select A.DEVICEID 
	  from PR_DEVICE_IN_VALUES AS A WITH (nolock)
	  where A.PARAMID = @aParamID
		and upper(CAST(PVALUE AS nvarchar(50))) like @aLot
  end
  
  return

end