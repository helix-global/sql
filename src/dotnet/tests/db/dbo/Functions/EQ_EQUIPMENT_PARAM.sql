CREATE function [dbo].[EQ_EQUIPMENT_PARAM](@EqID int, @ParamID int)
returns sql_variant as 
begin

  declare @res sql_variant;
  declare @pkind int;
  declare @pdatatype int;
  
  select @pkind = A.PARAMKIND
        ,@pdatatype = A.DATATYPE 
    from PR_MODELTYPE_PARAMS A with (nolock) 
   where A.ID = @ParamID
  
  if @pkind = 1 /*value*/
  begin
	  select top 1 @res = A.PVALUE 
	  from PR_OPERATION_PARAMS A with (nolock, forceseek(IX_PR_OPERATION_PARAMS_1(OPERID,PARAMID))/*KB2037*/ )
	  left join PR_OPERATION B with (nolock, forceseek (IX_PR_OPERATION_EQID(EQID))/*KB2037*/ ) on B.ID = A.OPERID
	  where B.EQID = @EqID
		and A.PARAMID = @ParamID
		and B.S_S in (1000013,1000019,1000116)
	  order by B.ID desc
	        
	  if @res is not null return @res

	  /* default */
	  declare @EqModelID int
	  
	  select @EqModelID = A.EQMODELID
	  from EQ_EQUIPMENT A with (nolock)
	  where A.ID = @EqID
	  
	  select top 1 @res = A.PVALUE 
	  from EQ_MODEL_PARAMS A with (nolock)
	  where A.VNESHID = @EqModelID
		and A.PARAMID = @ParamID
 
      if @res is not null return @res	  
  end
  else if @pkind = 2/*refvalue*/
  begin
	  declare @EqModelID2 int
	  declare @typeID int
	  
	  select @EqModelID2 = A.EQMODELID
	        ,@typeID = C.MTID
	  from EQ_EQUIPMENT A with (nolock)
	  left join EQ_MODELS B with (nolock) on B.ID = A.EQMODELID
	  left join EQ_TYPES C with (nolock) on C.ID = B.EQTYPEID
	  where A.ID = @EqID
	  
	  select top 1 @res = A.PVALUE 
	  from EQ_MODEL_PARAMS A with (nolock)
	  where A.VNESHID = @EqModelID2
		and A.PARAMID = @ParamID
		
      if @res is not null return @res
  
  	  select top 1 @res = A.VALUE 
	  from PR_MODELTYPE_COMMON_PARAMS A with (nolock)
	  left join PR_MODELTYPE_COMMON B with (nolock) on B.ID = A.TYPEID
	  where B.MTID = @typeID
		and A.PARAMID = @ParamID

  

  end
  
  return @res;  

end