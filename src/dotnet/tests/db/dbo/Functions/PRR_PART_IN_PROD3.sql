CREATE function [dbo].[PRR_PART_IN_PROD3](@aEmplID int, @ddd date)
returns int
as
begin

  declare @res int
  
  /*
	v.2   по дате (дню) 
  */
	
  declare @PartInProdOper int
  
  select top 1 @PartInProdOper = A.PARTINPRODUCTION
  from COM_EMPL_PARTINPROD A with(nolock)
  where A.EMPLID = @aEmplID and A.DD <= @ddd
  order by A.DD desc    
	
  
  /*
  логика раньше была такая, что если этой настройки нет вообще, то сотрудник работает в произ-ве 
  т.е. на 100%
  ... или? ... или что-то поменялось?
  */  
  
  return isnull(@PartInProdOper,100)  
  
end;