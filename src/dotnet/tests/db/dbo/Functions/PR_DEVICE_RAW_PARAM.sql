
--KB5192:2025-01-14: Forced using [IX_PR_OPERATION_PARAMS_1] index.
CREATE function [dbo].[PR_DEVICE_RAW_PARAM](@DeviceID int, @ParamID int)
returns sql_variant as 
begin
/* не учитывает состояние операций - выдает значения по незавершенным операциям */

  declare @res sql_variant;
  declare @pkind int;
  declare @pdatatype int;
  declare @revID int;
  declare @typeID int;
  declare @orderRowID int;
  
  select @pkind = A.PARAMKIND,@pdatatype = A.DATATYPE from PR_MODELTYPE_PARAMS A with(nolock) where A.ID = @ParamID
  
  if @pdatatype = 10 /* SW */
  begin
    select top 1 @res = B.NAME
    from PR_DEVICE_SW A with (nolock)
      left join SW_TOOL_VERSIONS B with(nolock) on B.ID = A.SWVERSIONID
    where A.DEVICEID = @DeviceID 
      and A.SWID = @ParamID
     
    return @res
  end
  
  if @pkind = 1 /*value*/
  begin
    select top 1 @res = A.PVALUE 
    from PR_OPERATION_PARAMS A with(nolock,index(IX_PR_OPERATION_PARAMS_1) /*KB5192*/)
      left join PR_OPERATION B with(nolock) on B.ID = A.OPERID
    where B.DEVICEID = @DeviceID
      and A.PARAMID = @ParamID
    /*and B.S_S in (1000013,1000019,1000116)*/
    order by B.ID desc

    if @res is not null return @res

    select top 1 @res = I.PVALUE 
    from PR_DEVICE_IN_VALUES I with(nolock)
    where I.DEVICEID = @DeviceID
      and I.PARAMID = @ParamID
    order by I.PACKETID desc

    if @res is not null return @res
    
    select top 1 @res = A.PVALUE 
    from PR_OPERATION_EXT_PARAMS A with(nolock)
      left join PR_OPERATION B with(nolock) on B.ID = A.OPERID
    where A.DEVICEID = @DeviceID
      and A.PARAMID = @ParamID
    /*and B.S_S in (1000013,1000019,1000116)*/
    order by B.ID desc
    
    if @res is not null return @res
    
    select top 1 @res = A.PVALUE 
    from PR_OPERATION_PARAMS A with(nolock,index(IX_PR_OPERATION_PARAMS_1) /*KB5192*/)
      left join PR_OPERATION B with(nolock) on B.ID = A.OPERID
    where A.OPERID in (select N.OPERID from PR_PARENT_OPERATION N with(nolock) where N.DEVICEID = @DeviceID and isnull(N.DONTUSEPARAMETERS,0) <> 1)
      and A.PARAMID = @ParamID
    /*and B.S_S in (1000013,1000019,1000116)*/
    order by B.ID desc

    if @res is not null return @res
    
    
    /* defaults */
    
    select @revID = A.REVID
          ,@typeID = B.TYPEID
    from PR_DEVICE A with (nolock) 
      left join PR_MODELS B with(nolock) on B.ID = A.MODELID
    where A.ID = @DeviceID
    
    select top 1 @res = A.PVALUE 
    from PR_REV_PARAMS A with(nolock)
    where A.REVISIONID = @revID
      and A.PARAMID = @ParamID
      and A.ONLYOPTION in (select G.OPTID from PR_DEVICE_OPT G with(nolock) where G.DEVICEID = @DeviceID)

    if @res is not null return @res
      
    select top 1 @res = A.VALUE 
    from PR_MODELTYPE_COMMON_PARAMS A with(nolock)
      left join PR_MODELTYPE_COMMON B with(nolock) on B.ID = A.TYPEID
    where B.MTID = @typeID
      and A.PARAMID = @ParamID
      and A.OPTIONID in (select G.OPTID from PR_DEVICE_OPT G with(nolock) where G.DEVICEID = @DeviceID)

      if @res is not null return @res
      
    select top 1 @res = A.PVALUE 
    from PR_REV_PARAMS A with(nolock)
    where A.REVISIONID = @revID
      and A.PARAMID = @ParamID
      and A.ONLYOPTION is null

    if @res is not null return @res

    select top 1 @res = A.VALUE 
    from PR_MODELTYPE_COMMON_PARAMS A with(nolock)
      left join PR_MODELTYPE_COMMON B with(nolock) on B.ID = A.TYPEID
    where B.MTID = @typeID
      and A.PARAMID = @ParamID
      and A.OPTIONID is null
  
    if @res is not null return @res    
  end
  else if @pkind = 2/*refvalue*/
  begin
    select @revID = A.REVID
             ,@typeID = B.TYPEID
             ,@orderRowID = A.ORDERROWID
    from PR_DEVICE A with(nolock) 
      left join PR_MODELS B with(nolock) on B.ID = A.MODELID
    where A.ID = @DeviceID
  
    if (@orderRowID is not null)  /* параметр был передан с заказом */
    begin
      select top 1 @res = A.PVALUE 
      from PR_PRORDER_TP A with(nolock)
        where A.OPID = @orderRowID
          and A.PARAMID = @ParamID
  
      if @res is not null return @res
    end
  
    select top 1 @res = A.PVALUE 
    from PR_REV_PARAMS A with(nolock)
    where A.REVISIONID = @revID
      and A.PARAMID = @ParamID
      and A.ONLYOPTION in (select G.OPTID from PR_DEVICE_OPT G with(nolock) where G.DEVICEID = @DeviceID)

    if @res is not null return @res

    select top 1 @res = A.VALUE 
    from PR_MODELTYPE_COMMON_PARAMS A with(nolock)
      left join PR_MODELTYPE_COMMON B with(nolock) on B.ID = A.TYPEID
    where B.MTID = @typeID
      and A.PARAMID = @ParamID
      and A.OPTIONID in (select G.OPTID from PR_DEVICE_OPT G with(nolock) where G.DEVICEID = @DeviceID)

    if @res is not null return @res

    select top 1 @res = A.PVALUE 
    from PR_REV_PARAMS A with(nolock)
    where A.REVISIONID = @revID
      and A.PARAMID = @ParamID
      and A.ONLYOPTION is null

    if @res is not null return @res

    select top 1 @res = A.VALUE 
    from PR_MODELTYPE_COMMON_PARAMS A with(nolock)
      left join PR_MODELTYPE_COMMON B with(nolock) on B.ID = A.TYPEID
    where B.MTID = @typeID
      and A.PARAMID = @ParamID
      and A.OPTIONID is null
  
    if @res is not null return @res    
    
  end
  
  return @res;  

end