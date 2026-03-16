CREATE function [dbo].[PR_DEVICE_PARAM_IN_LIST_STR2](@DevID int,@DevModelTypeID int,@ParamNumber int)
returns nvarchar(200) as
begin
  declare @ParamID int
  declare @ParamDataType int

  select top 1
     @ParamID=[mdlP].[ID]
    ,@ParamDataType=[mdlP].[DATATYPE]
  from [dbo].[PR_MODELTYPE_PARAMS] [mdlP] with(nolock)
  where [mdlP].[TYPEID]=@DevModelTypeID
    and [mdlP].[USEINLIST]=@ParamNumber

  if @ParamID is not null
  begin
    declare @ParamValue sql_variant
    declare @ParamREF int

    select
       @ParamValue = [cache].[PVALUE]
      ,@ParamREF = [cache].[PARAMID]
    from [dbo].[PR_LIST_PARAMS_CACHE] [cache] with(nolock)
    where [cache].[DEVICEID] = @DevID
      and [cache].[PARAMID] = @ParamID

    if (@ParamREF is null)
    begin
      set @ParamValue = [dbo].[PR_DEVICE_PARAM](@DevID,@ParamID)
    end

    if (@ParamValue is null)
    begin
      return null
    end

    if @ParamDataType = 9 /*date*/
    begin
      declare @dd date
      declare @dds nvarchar(50)
      set @dds = cast(@ParamValue as nvarchar(50))
      set @dds = ltrim(rtrim(@dds))

      if len(@dds) = 8  /* 01.01.50 */
      begin
        set @dd = convert(date,@dds,4)
        return convert(varchar,@dd,104)
      end else
      begin
        set @dd = convert(date,@ParamValue,104)
        return convert(varchar,@dd,104)
      end
    end else
    if @ParamDataType = 2 /*datetime*/
    begin
      declare @dt datetime
      set @dt = cast(@ParamValue as datetime)
      return convert(varchar,@dt,104) + ' ' + convert(varchar,@dt,108)
    end

    return cast(@ParamValue as nvarchar(200))
  end
  return null
end