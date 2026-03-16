create function [dbo].[PR_DEVICE_PARAM_IN_OPLIST_STR4](@DeviceID int, @MtID int, @ParamN int,@OperationID int,@OperMTID int)
returns nvarchar(200) as 
begin
/*
  04.11.14 скопирована с PR_DEVICE_PARAM_IN_LIST_STR2
  с целью использования ТОЛЬКО в списках ОПЕРАЦИЙ 
  и вывода параметров из операций по подготовительным операциям (@DeviceID is null)
*/
  
 if @DeviceID is not null 
   return dbo.PR_DEVICE_PARAM_IN_OPLIST_STR2(@DeviceID,@MtID,@ParamN)
 else if @OperationID is not null
 begin  


  declare @prmID int
  declare @prmDataType int
  declare @dtv sql_variant
  
  select top 1 @prmID = A.ID , @prmDataType = A.DATATYPE
  from PR_MODELTYPE_PARAMS A with (nolock) 
  where A.TYPEID = @OperMTID
   and A.USEINOPLIST = @ParamN

  declare @dt datetime  
  declare @dd date
  declare @dds nvarchar(50)
  
  if @prmID is not null
  begin
 
    select top 1 @dtv = A.PVALUE from PR_OPERATION_PARAMS A with (nolock) where A.OPERID = @OperationID and A.PARAMID = @prmID order by A.ID desc
     
    if @prmDataType = 9 /*date*/
    begin
      if (@dtv is not null)
      begin
         set @dds = cast(@dtv as nvarchar(50)) 
         set @dds = ltrim(rtrim(@dds))
         if len(@dds) = 8  /* 01.01.50 */
         begin
           set @dd = convert(date,@dds,4)
           return convert(varchar,@dd,104)
         end
         else
         begin
           set @dd = convert(date,@dtv,104)
           return convert(varchar,@dd,104)
         end  
      end  
    end
    else if @prmDataType = 2 /*datetime*/
    begin
      if (@dtv is not null)
      begin
         set @dt = CAST(@dtv as datetime)
         return convert(varchar,@dt,104) + ' ' + convert(varchar,@dt,108)
      end  
    end
    else 
      return cast (@dtv as nvarchar(200)) 
  end

 end
  
 return null
end