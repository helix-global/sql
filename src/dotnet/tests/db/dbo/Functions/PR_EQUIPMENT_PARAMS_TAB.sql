CREATE function [dbo].[PR_EQUIPMENT_PARAMS_TAB] (@aEqID int)
returns @res table (ID int,NAME nvarchar(300),DATATYPE int,VALUE sql_variant,SYMBOL nvarchar(100),UNITSTR nvarchar(50),PARAMKIND int)
as 
begin

  declare @mtID int 
  declare @eqModelID int
  
  select @mtID = C.MTID
        ,@eqModelID = A.EQMODELID
  from EQ_EQUIPMENT A with (nolock)
  left join EQ_MODELS B with (nolock) on B.ID = A.EQMODELID
  left join EQ_TYPES C with (nolock) on C.ID = B.EQTYPEID
  where A.ID = @aEqID

  insert into @res (ID, VALUE,  NAME, DATATYPE, SYMBOL, UNITSTR, PARAMKIND)
  select C.ID, M2.VALUE, C.NAME, C.DATATYPE, C.SYMBOL, C.UNITSTR, C.PARAMKIND
  from PR_MODELTYPE_PARAMS C with (nolock) 
  left join (
	  select M.PARAMID 
	  , dbo.EQ_EQUIPMENT_PARAM(@aEqID, M.PARAMID) as VALUE
	  from (
	               select A.PARAMID 
	                 from PR_OPERATION_PARAMS A with (nolock)
	                 left join PR_OPERATION B with (nolock) on B.ID = A.OPERID
	                 where B.EQID = @aEqID
	                 union 
	                select A.PARAMID
	                  from EQ_MODEL_PARAMS A with (nolock)
	                 where A.VNESHID = @eqModelID
	            )M
				  ) M2 on M2.PARAMID = C.ID
  where C.TYPEID = @mtID


  return

end