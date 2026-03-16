CREATE function [dbo].[SM_GETSERVICEP_PARAMS](@aServiceProtocolID int,@aParamID int)
returns @res table (PARAMROWID int, PARAMID int, DATATYPE int, PVALUE sql_variant, PVALUE_STR nvarchar(max)) as 
begin

  insert into @res (PARAMROWID, PARAMID, DATATYPE, PVALUE, PVALUE_STR)
  select A.PARAMROWID,B.PARAMID,C.DATATYPE,B.PVALUE,cast (B.PVALUE as nvarchar)
  from SM_SERVICEPROTOCOL_PARAMS A with (nolock)
  left join PR_OPERATION_PARAMS B with (nolock) on B.ID = A.PARAMROWID
  left join PR_MODELTYPE_PARAMS C with (nolock) on C.ID = B.PARAMID
  where A.VNESHID = @aServiceProtocolID
    and B.PARAMID = @aParamID
  
  return

end