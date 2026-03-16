create function [dbo].[PRR_IS100PERCENT_KB4248](@aEmplID int, @yyyy int, @mm int)
returns int
as
begin

  /*
  По KB4248 оказывается что "подразумевалось" Production Support и Non-Production будут 
  не только операциями (special type 100 и 101), а миксом: один день так (100% без операций), другой эдак (по операциям)
  Как делать этот микс непонятно => по примеру из KB4248:
  Если на начало месяца @yyyy @mm у сотрудника стоит:
  0 в "Part in Production Operations" и нет 1 в "Allow Non-production and Production support.."
  То:
  если выбран тип в поле "Production Support" то возвращаем 101 
  иначе если стоит "Yes" в поле "Non-production" и выбран тип в поле "Non-Production type" то возвращаем 100
  
  иначе 0
  
  По ответу 100 или 101 процедура расчета все время положит заместо времени из соответствующих операций 
   
  */
  
  declare @settingDate datetime = dbo.COM_ENCODE_DATE(@yyyy,@mm,1)
  declare @settingID int
  
  declare @PartInProdOper int
  declare @AllowNon int
  declare @ProdSupport int
  declare @NonProduction int
  declare @NonProductionType int
  
  select top 1 @settingID = A.ID 
	,@PartInProdOper = A.PARTINPRODUCTION
	,@AllowNon = isnull(A.ALLOW_NON_PS,0)
	,@ProdSupport = A.PRODSUPPORT
	,@NonProduction = A.ISRANDD
	,@NonProductionType = A.NONPRODTYPE
  from COM_EMPL_PARTINPROD A with(nolock)
  where A.EMPLID = @aEmplID
    and A.DD <= @settingDate
  order by A.DD desc    
  
  if @settingID is null
    return 0
    
  if @PartInProdOper = 0 and @AllowNon <> 1
  begin

	if @ProdSupport is not null
      return 101
      
    if @NonProduction = 1 /*Yes*/ and @NonProductionType is not null
      return 100
  
  end

  return 0
  
end;