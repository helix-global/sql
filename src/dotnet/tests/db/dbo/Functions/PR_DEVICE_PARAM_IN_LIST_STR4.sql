CREATE function [dbo].[PR_DEVICE_PARAM_IN_LIST_STR4](@DevID int,@DevModelTypeID int,@ParamNumber int,@OperID int,@OperTypeModelTypeID int)
returns nvarchar(200) as
begin
  /*
    04.11.14 скопирована с PR_DEVICE_PARAM_IN_LIST_STR2
    с целью использования ТОЛЬКО в списках ОПЕРАЦИЙ 
    и вывода параметров из операций по подготовительным операциям (@DevID is null)
  */

  if @DevID is not null
  begin
    return [dbo].[PR_DEVICE_PARAM_IN_LIST_STR2](@DevID,@DevModelTypeID,@ParamNumber)
  end else
  if @OperID is not null
  begin
    declare @ParamID int
    declare @ParamDataType int
    declare @ParamValue sql_variant

    select top 1
       @ParamID = [mdlP].[ID]
      ,@ParamDataType = [mdlP].[DATATYPE]
    from [dbo].[PR_MODELTYPE_PARAMS] [mdlP] with(nolock)
    where [mdlP].[TYPEID] = @OperTypeModelTypeID
      and [mdlP].[USEINLIST] = @ParamNumber

    declare @dt datetime
    declare @dd date
    declare @dds nvarchar(50)

    if @ParamID is not null
    begin
      select top 1
        @ParamValue = [oprP].[PVALUE]
      from [dbo].[PR_OPERATION_PARAMS] [oprP] with(nolock)
      where [oprP].[OPERID] = @OperID
        and [oprP].[PARAMID] = @ParamID
      order by [oprP].[ID] desc

      if @ParamDataType = 9 /*date*/
      begin
        if (@ParamValue is not null)
        begin
           set @dds = cast(@ParamValue as nvarchar(50))
           set @dds = ltrim(rtrim(@dds))
           if len(@dds) = 8  /* 01.01.50 */
           begin
             set @dd = convert(date,@dds,4)
             return convert(varchar,@dd,104)
           end
           else
           begin
             set @dd = convert(date,@ParamValue,104)
             return convert(varchar,@dd,104)
           end
        end
      end else
      if @ParamDataType = 2 /*datetime*/
      begin
        if (@ParamValue is not null)
        begin
          set @dt = CAST(@ParamValue as datetime)
          return convert(varchar,@dt,104) + ' ' + convert(varchar,@dt,108)
        end
      end
      else
      begin
        return cast (@ParamValue as nvarchar(200))
      end
    end
  end
  return null
end