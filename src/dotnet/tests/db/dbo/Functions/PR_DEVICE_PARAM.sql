CREATE function [dbo].[PR_DEVICE_PARAM](@DeviceID int,@ParamID int)
returns sql_variant as
begin
  declare @RetVal sql_variant
  declare @ParamKind int
  declare @ParamDataType int
  declare @RevID int
  declare @ModelTypeID int
  declare @OrderRowID int

  -- Determines the kind and data type of the parameter by the ID.
  select
     @ParamKind=[mdlP].[PARAMKIND]
    ,@ParamDataType=[mdlP].[DATATYPE]
  from [dbo].[PR_MODELTYPE_PARAMS] [mdlP] with(nolock)
  where [mdlP].[ID]=@ParamID

  if @ParamDataType = 10 /* SW */
  begin
    select top 1
      @RetVal = [b].[NAME]
    from [dbo].[PR_DEVICE_SW] [a] with(nolock)
      left join [dbo].[SW_TOOL_VERSIONS] [b] with(nolock) on [b].[ID]=[a].[SWVERSIONID]
    where [a].[DEVICEID] = @DeviceID
      and [a].[SWID] = @ParamID

    return @RetVal
  end

  if @ParamKind = 1 /*value*/
  begin
    select top 1
      @RetVal=[oprP].[PVALUE]
    from [dbo].[PR_OPERATION_PARAMS] [oprP] with(nolock,index (IX_PR_OPERATION_PARAMS_1) /*Ticket35629*/)
      left join [dbo].[PR_OPERATION] [oper] with(nolock) on [oper].[ID]=[oprP].[OPERID]
    where [oper].[DEVICEID] = @DeviceID
      and [oprP].[PARAMID] = @ParamID
      and [oper].[S_S] in (1000013,1000019,1000116)
    order by [oper].[ID] desc

    if @RetVal is not null
    begin
      return @RetVal
    end

    select top 1
      @RetVal = [dvIv].[PVALUE]
    from [dbo].[PR_DEVICE_IN_VALUES] [dvIv] with(nolock)
    where [dvIv].[DEVICEID] = @DeviceID
      and [dvIv].[PARAMID] = @ParamID
    order by [dvIv].[PACKETID] desc

    if @RetVal is not null
    begin
      return @RetVal
    end

    select top 1
      @RetVal = [oprE].[PVALUE]
    from [dbo].[PR_OPERATION_EXT_PARAMS] [oprE] with(nolock)
      inner join [dbo].[PR_OPERATION] [oper] with(nolock) on [oper].[ID]=[oprE].[OPERID]
    where [oprE].[DEVICEID]=@DeviceID
      and [oprE].[PARAMID]=@ParamID
      and [oper].[S_S] in (1000013,1000019,1000116)
    order by [oper].[ID] desc

    if @RetVal is not null
    begin
      return @RetVal
    end

    select top 1
      @RetVal = [oprP].[PVALUE]
    from [dbo].[PR_OPERATION_PARAMS] [oprP] with(nolock,index (IX_PR_OPERATION_PARAMS_1) /*Ticket35629*/)
      left join [dbo].[PR_OPERATION] [oper] with(nolock) on [oper].[ID]=[oprP].[OPERID]
    where [oprP].[OPERID] in (select [parO].[OPERID]
                              from [dbo].[PR_PARENT_OPERATION] [parO] with(nolock)
                              where [parO].[DEVICEID] = @DeviceID
                                and isnull([parO].[DONTUSEPARAMETERS],0) <> 1)
      and [oprP].[PARAMID] = @ParamID
      and [oper].[S_S] in (1000013,1000019,1000116)
    order by [oper].[ID] desc

    if @RetVal is not null
    begin
      return @RetVal
    end

    /* defaults */
    select
       @RevID  = [devi].[REVID]
      ,@ModelTypeID = [modl].[TYPEID]
    from [dbo].[PR_DEVICE] [devi] with(nolock)
      inner join [dbo].[PR_MODELS] [modl] with(nolock) on [modl].[ID] = [devi].[MODELID]
    where [devi].[ID] = @DeviceID

    select top 1
      @RetVal = [revP].[PVALUE]
    from [dbo].[PR_REV_PARAMS] [revP] with(nolock)
    where [revP].[REVISIONID] = @RevID
      and [revP].[PARAMID] = @ParamID
      and [revP].[ONLYOPTION] in (select [devO].[OPTID]
                                  from [dbo].[PR_DEVICE_OPT] [devO] with(nolock)
                                  where [devO].[DEVICEID] = @DeviceID)

    if @RetVal is not null
    begin
      return @RetVal
    end

    select top 1
      @RetVal = [mdcP].[VALUE]
    from [dbo].[PR_MODELTYPE_COMMON_PARAMS] [mdcP] with(nolock)
      left join [dbo].[PR_MODELTYPE_COMMON] [mdtc] with(nolock) on [mdtc].[ID] = [mdcP].[TYPEID]
    where [mdtc].[MTID] = @ModelTypeID
      and [mdcP].[PARAMID] = @ParamID
      and [mdcP].[OPTIONID] in (select [devO].[OPTID]
                                from [dbo].[PR_DEVICE_OPT] [devO] with(nolock)
                                where [devO].[DEVICEID] = @DeviceID)

    if @RetVal is not null
    begin
      return @RetVal
    end

    select top 1
      @RetVal = [revP].[PVALUE]
    from [dbo].[PR_REV_PARAMS] [revP] with(nolock)
    where [revP].[REVISIONID] = @RevID
      and [revP].[PARAMID] = @ParamID
      and [revP].[ONLYOPTION] is null

    if @RetVal is not null
    begin
      return @RetVal
    end

    select top 1
      @RetVal = [mdcP].[VALUE]
    from [dbo].[PR_MODELTYPE_COMMON_PARAMS] [mdcP] with(nolock)
      left join [dbo].[PR_MODELTYPE_COMMON] [mdtc] with(nolock) on [mdtc].[ID] = [mdcP].[TYPEID]
    where [mdtc].[MTID] = @ModelTypeID
      and [mdcP].[PARAMID] = @ParamID
      and [mdcP].[OPTIONID] is null

    if @RetVal is not null
    begin
      return @RetVal
    end
  end
  else if @ParamKind = 2/*refvalue*/
  begin
    select
       @RevID = [devi].[REVID]
      ,@ModelTypeID = [modl].[TYPEID]
      ,@OrderRowID = [devi].[ORDERROWID]
    from [dbo].[PR_DEVICE] [devi] with(nolock)
      inner join [dbo].[PR_MODELS] [modl] with(nolock) on [modl].[ID] = [devi].[MODELID]
    where [devi].[ID] = @DeviceID

    if (@OrderRowID is not null)  /* параметр был передан с заказом */
    begin
      select top 1
        @RetVal = [pord].[PVALUE]
      from [dbo].[PR_PRORDER_TP] [pord] with(nolock)
      where [pord].[OPID] = @OrderRowID
        and [pord].[PARAMID] = @ParamID

      if @RetVal is not null
      begin
        return @RetVal
      end
    end

    select top 1
      @RetVal = [revP].[PVALUE]
    from [dbo].[PR_REV_PARAMS] [revP] with(nolock)
    where [revP].[REVISIONID] = @RevID
      and [revP].[PARAMID]= @ParamID
      and [revP].[ONLYOPTION]  in (select [devO].[OPTID] from [dbo].[PR_DEVICE_OPT] [devO] with(nolock) where [devO].[DEVICEID] = @DeviceID)
      and [revP].[ONLYOPTION2] in (select [devO].[OPTID] from [dbo].[PR_DEVICE_OPT] [devO] with(nolock) where [devO].[DEVICEID] = @DeviceID)
      and [revP].[ONLYOPTION3] in (select [devO].[OPTID] from [dbo].[PR_DEVICE_OPT] [devO] with(nolock) where [devO].[DEVICEID] = @DeviceID)

    if @RetVal is not null
    begin
      return @RetVal
    end

    select top 1
      @RetVal = [revP].[PVALUE]
    from [dbo].[PR_REV_PARAMS] [revP] with(nolock)
    where [revP].[REVISIONID] = @RevID
      and [revP].[PARAMID] = @ParamID
      and [revP].[ONLYOPTION]  in (select [devO].[OPTID] from [dbo].[PR_DEVICE_OPT] [devO] with(nolock) where [devO].[DEVICEID] = @DeviceID)
      and [revP].[ONLYOPTION2] in (select [devO].[OPTID] from [dbo].[PR_DEVICE_OPT] [devO] with(nolock) where [devO].[DEVICEID] = @DeviceID)
      and [revP].[ONLYOPTION3] is null

    if @RetVal is not null
    begin
      return @RetVal
    end

    select top 1
      @RetVal = [revP].[PVALUE]
    from [dbo].[PR_REV_PARAMS] [revP] with(nolock)
    where [revP].[REVISIONID] = @RevID
      and [revP].[PARAMID] = @ParamID
      and [revP].[ONLYOPTION]  in (select [devO].[OPTID] from [dbo].[PR_DEVICE_OPT] [devO] with(nolock) where [devO].[DEVICEID] = @DeviceID)
      and [revP].[ONLYOPTION2] is null
      and [revP].[ONLYOPTION3] is null

    if @RetVal is not null
    begin
      return @RetVal
    end

    select top 1
      @RetVal = [mdcP].[VALUE]
    from [dbo].[PR_MODELTYPE_COMMON_PARAMS] [mdcP] with(nolock)
      left join [dbo].[PR_MODELTYPE_COMMON] [mdtc] with(nolock) on [mdtc].[ID] = [mdcP].[TYPEID]
    where [mdtc].[MTID] = @ModelTypeID
      and [mdcP].[PARAMID] = @ParamID
      and [mdcP].[OPTIONID] in (select [devO].[OPTID] from [dbo].[PR_DEVICE_OPT] [devO] with(nolock) where [devO].[DEVICEID] = @DeviceID)

    if @RetVal is not null
    begin
      return @RetVal
    end

    select top 1
      @RetVal = [revP].[PVALUE]
    from [dbo].[PR_REV_PARAMS] [revP] with(nolock)
    where [revP].[REVISIONID] = @RevID
      and [revP].[PARAMID] = @ParamID
      and [revP].[ONLYOPTION] is null
      and [revP].[ONLYOPTION2] is null
      and [revP].[ONLYOPTION3] is null

    if @RetVal is not null
    begin
      return @RetVal
    end

    select top 1
      @RetVal = [mdcP].[VALUE]
    from [dbo].[PR_MODELTYPE_COMMON_PARAMS] [mdcP] with(nolock)
      left join [dbo].[PR_MODELTYPE_COMMON] [mdtc] with(nolock) on [mdtc].[ID] = [mdcP].[TYPEID]
    where [mdtc].[MTID] = @ModelTypeID
      and [mdcP].[PARAMID] = @ParamID
      and [mdcP].[OPTIONID] is null

    if @RetVal is not null
    begin
      return @RetVal
    end

    if (@RevID is null)
    begin
      /* изделия, принятые из файла иногда не имеют ревизии, но имеют значения референсных параметров */
      select top 1
        @RetVal = [oprP].[PVALUE]
      from [dbo].[PR_OPERATION_PARAMS] [oprP] with(nolock, index (IX_PR_OPERATION_PARAMS_1) /*Ticket35629*/)
        left join [dbo].[PR_OPERATION] [oper] with(nolock) on [oper].[ID] = [oprP].[OPERID]
      where [oper].[DEVICEID] = @DeviceID
        and [oprP].[PARAMID] = @ParamID
        and [oper].[S_S] in (1000013,1000019,1000116)
      order by [oper].[ID] desc

      if @RetVal is not null
      begin
        return @RetVal
      end

      select top 1
        @RetVal = [dvIv].[PVALUE]
      from [dbo].[PR_DEVICE_IN_VALUES] [dvIv] with(nolock)
      where [dvIv].[DEVICEID] = @DeviceID
        and [dvIv].[PARAMID] = @ParamID
      order by [dvIv].[PACKETID] desc

      if @RetVal is not null
      begin
        return @RetVal
      end
    end
  end
  return @RetVal;
end