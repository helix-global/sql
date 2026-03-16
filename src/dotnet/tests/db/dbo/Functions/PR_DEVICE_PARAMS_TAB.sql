CREATE function dbo.PR_DEVICE_PARAMS_TAB (@aDeviceID int)
returns @res table (ID int,NAME nvarchar(300),DATATYPE int,VALUE sql_variant,SYMBOL nvarchar(100),UNITSTR nvarchar(50),PARAMKIND int)
as 
begin

  declare @revID int
  declare @modelID int
  declare @mtID int 
  declare @orderRowID int 
  
  select @revID = A.REVID
        ,@modelID = A.MODELID
        ,@mtID = B.TYPEID
        ,@orderRowID = A.ORDERROWID
  from PR_DEVICE A with (nolock)
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID
  where A.ID = @aDeviceID

  insert into @res (ID, VALUE,  NAME, DATATYPE, SYMBOL, UNITSTR, PARAMKIND)
  select C.ID, M2.VALUE, C.NAME, C.DATATYPE, C.SYMBOL, C.UNITSTR, C.PARAMKIND
  from PR_DEVICE A with (nolock)
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID
  left join PR_MODELTYPE_PARAMS C with (nolock) on C.TYPEID = B.TYPEID
  left join (
	  select M.PARAMID 
	  , dbo.PR_DEVICE_PARAM(@aDeviceID, M.PARAMID) as VALUE
	  from (
	                select A.PARAMID 
	                 from PR_OPERATION_PARAMS A with (nolock)
	                 left join PR_OPERATION B with (nolock) on B.ID = A.OPERID
	                 where B.DEVICEID = @aDeviceID
	                 union 
                  select A.PARAMID 
              	   from PR_OPERATION_PARAMS A with (nolock)
              	   left join PR_OPERATION B with (nolock) on B.ID = A.OPERID
              	   where A.OPERID in (select N.OPERID from PR_PARENT_OPERATION N with (nolock) where N.DEVICEID = @aDeviceID and isnull(N.DONTUSEPARAMETERS,0) <> 1)
                    union 
	                select A.PARAMID
	                  from PR_DEVICE_IN_VALUES A with (nolock)
	                 where A.DEVICEID = @aDeviceID
	                 union 
	                select A.PARAMID
	                  from PR_REV_PARAMS A with (nolock)
	                 where A.REVISIONID = @revID
	                 union 
	                select A.SWID
	                  from PR_DEVICE_SW A with (nolock)
	                 where A.DEVICEID = @aDeviceID
	                 union
	                select A.PARAMID
	                  from PR_OPERATION_EXT_PARAMS A with (nolock)
	                 where A.DEVICEID = @aDeviceID
	                 union 
	                select A.PARAMID
	                  from PR_MODELTYPE_COMMON_PARAMS A with (nolock)
	                  left join PR_MODELTYPE_COMMON B with (nolock) on B.ID = A.TYPEID
	                 where B.MTID = @mtID
	                 union
	                select A.PARAMID
	                  from PR_PRORDER_TP A with (nolock)
	                 where A.OPID = @orderRowID 
	            )M
				  ) M2 on M2.PARAMID = C.ID
  where A.ID = @aDeviceID


  return

end