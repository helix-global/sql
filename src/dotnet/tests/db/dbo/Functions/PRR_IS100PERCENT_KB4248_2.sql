CREATE function [dbo].[PRR_IS100PERCENT_KB4248_2](@aEmplID int, @ddd date)
returns int
as
begin

  /*
	v.2   по дате (дню) 
	чтобы не запутаться: если эта функция возвращает 100 или 101, то вместо 
	суммы elapsed time из операций 100 и 101 должно браться "все доступное время" 
	
	100	 - Non-production operation
	101	 - Production support operation

  */
  
  declare @PartInProdOper int
  declare @AllowNon int
  declare @ProdSupport int
  declare @NonProduction int
  declare @NonProductionType int
  
  select top 1 @PartInProdOper = A.PARTINPRODUCTION
  from COM_EMPL_PARTINPROD A with(nolock)
  where A.EMPLID = @aEmplID and A.DD <= @ddd
  order by A.DD desc    
  
  select top 1 @AllowNon = isnull(A.ALLOW_NON_PS,0)
  from COM_EMPL_PARTINPROD A with(nolock)
  where A.EMPLID = @aEmplID and A.DD <= @ddd
  order by A.DD desc    

  select top 1 @ProdSupport = A.PRODSUPPORT
  from COM_EMPL_PARTINPROD A with(nolock)
  where A.EMPLID = @aEmplID and A.DD <= @ddd
  order by A.DD desc    
  
  select top 1 @NonProduction = A.ISRANDD
  from COM_EMPL_PARTINPROD A with(nolock)
  where A.EMPLID = @aEmplID and A.DD <= @ddd
  order by A.DD desc    
  
  select top 1 @NonProductionType = A.NONPRODTYPE
  from COM_EMPL_PARTINPROD A with(nolock)
  where A.EMPLID = @aEmplID and A.DD <= @ddd
  order by A.DD desc    
    
  if @PartInProdOper = 0 and @AllowNon <> 1
  begin

	if @ProdSupport is not null
      return 101
      
    if @NonProduction = 1 /*Yes*/ and @NonProductionType is not null
      return 100
  
  end

  return 0
  
end;