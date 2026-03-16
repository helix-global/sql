CREATE function [dbo].[PR_REVISION_PARAM](@RevisionID int, @ParamID int)
returns sql_variant as 
begin
  declare @res sql_variant;
  declare @pkind int;
  declare @pdatatype int;
  declare @typeID int;
  
  select @pkind = A.PARAMKIND
        ,@pdatatype = A.DATATYPE 
    from PR_MODELTYPE_PARAMS A with (nolock) where A.ID = @ParamID
  
  if @pdatatype = 10 /* SW */
  begin
     /* TODO найти ? */ 
     return @res
  end
  
  if @pkind = 1
  begin
	  select top 1 @res = A.PVALUE 
	  from PR_REV_PARAMS A with (nolock)
	  where A.REVISIONID = @RevisionID
		and A.PARAMID = @ParamID
		and A.ONLYOPTION is null

	  
  end
  else if @pkind = 2
  begin

		  select top 1 @res = A.PVALUE 
		  from PR_REV_PARAMS A with (nolock)
		  where A.REVISIONID = @RevisionID
			and A.PARAMID = @ParamID
			and A.ONLYOPTION is null
			
          if @res is not null return @res			
          
          select @typeID = B.TYPEID
            from PR_REVISION A with (nolock) 
            left join PR_MODELS B  with (nolock) on B.ID = A.MODELID
            where A.ID = @RevisionID
          
		  select top 1 @res = A.VALUE 
		  from PR_MODELTYPE_COMMON_PARAMS A with (nolock)
		  left join PR_MODELTYPE_COMMON B with (nolock) on B.ID = A.TYPEID
		  where B.MTID = @typeID
			and A.PARAMID = @ParamID
			and A.OPTIONID is null          


  end
  
  return @res;  

end