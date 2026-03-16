CREATE function [dbo].[PR_ORDERROW_PARAM](@OrderRowID int, @ParamID int)
returns sql_variant as 
begin
/*
функция написана чтобы учитывать опции, заложенные в сроке заказа
т.к. функция PR_REVISION_PARAM опции не учитывает (неоткуда)
а PR_DEVICE_PARAM неудобно применять при создании дочерних заказов
*/

  declare @res sql_variant;
  declare @pkind int;
  declare @pdatatype int;
  declare @revID int;
  declare @typeID int;
  
  
  select @pkind = A.PARAMKIND
        ,@pdatatype = A.DATATYPE 
   from PR_MODELTYPE_PARAMS A with (nolock) where A.ID = @ParamID
  
  select @revID = A.REVID
       , @typeID = B.TYPEID
  from PR_PRORDER_T A with (nolock) 
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID 
  where A.ID = @OrderRowID
  
  if @pdatatype = 10 /* SW */
  begin
     select @res = A.NAME from SW_TOOLS A where A.ID = dbo.PR_ORDERROW_SWID(@OrderRowID, @ParamID)
     return @res
  end
  
  if @pkind = 2
  begin

     declare @opts table (ID int)
     insert into @opts (ID)
     select distinct G.OPTID from PR_PRORDER_TO G where G.OPID = @OrderRowID
     /*predefined*/
     insert into @opts (ID)
     select distinct G.OPTIONID 
     from PR_PRORDER_T A with (nolock)
     left join PR_MODEL_OPTIONS G on G.MODELID = A.MODELID
     where A.ID = @OrderRowID
       and isnull(G.PREDEFINEDOPT,0) = 1
       and not exists (select H.ID from @opts H where H.ID = G.OPTIONID)

	  select top 1 @res = A.PVALUE 
	  from PR_REV_PARAMS A with (nolock)
	  where A.REVISIONID = @revID
	    and A.PARAMID = @ParamID
	    and A.ONLYOPTION in (select ID from @opts)

      if @res is not null return @res

	  select top 1 @res = A.VALUE 
	  from PR_MODELTYPE_COMMON_PARAMS A with (nolock)
	  left join PR_MODELTYPE_COMMON B with (nolock) on B.ID = A.TYPEID
	  where B.MTID = @typeID
		and A.PARAMID = @ParamID
		and A.OPTIONID in (select ID from @opts)

      if @res is not null return @res

      select top 1 @res = A.PVALUE 
	  from PR_REV_PARAMS A with (nolock)
	  where A.REVISIONID = @revID
		and A.PARAMID = @ParamID
		and A.ONLYOPTION is null

      if @res is not null return @res

	  select top 1 @res = A.VALUE 
	  from PR_MODELTYPE_COMMON_PARAMS A with (nolock)
	  left join PR_MODELTYPE_COMMON B with (nolock) on B.ID = A.TYPEID
	  where B.MTID = @typeID
		and A.PARAMID = @ParamID
		and A.OPTIONID is null
  
      if @res is not null return @res	  

  end
  
  return @res;  

end