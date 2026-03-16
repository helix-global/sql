create function [dbo].[PR_EQUIPMENT_PARAMS_TAB2] (@aEqID int, @aUserID int)
returns @res table (ID int,NAME nvarchar(300),DATATYPE int,VALUE sql_variant,SYMBOL nvarchar(100),UNITSTR nvarchar(50),PARAMKIND int)
as 
begin

  declare @eqModelID int
  
  select @eqModelID = A.EQMODELID
  from EQ_EQUIPMENT A with (nolock)
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
  where C.TYPEID in (select ID from dbo.EQ_MTIDS_BY_EQID(@aEqID,@aUserID))


  return

end