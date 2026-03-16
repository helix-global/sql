create function [dbo].MNT_EQ_CYCLES_FROMPARAMS(@aOperID int, @aPlanID int)
returns int as 
begin
  /*KB3719
  функция берет кол-во использований оборудования из параметра если параметры перечислены на плане
  если не перечислены - возвращает 1 (как раньше по числу операций)
  */
  if exists (select * from MNT_PLAN_EQ_PARAMS with(nolock) where VNESHID = @aPlanID)
  begin
	
	declare @res int
	select @res = sum(cast(A.PVALUE as int)) 
	from PR_OPERATION_PARAMS A with(nolock)
	where A.OPERID = @aOperID
	  and A.PARAMID in (select B.PARAMID from MNT_PLAN_EQ_PARAMS B with(nolock) where B.VNESHID = @aPlanID)
	  
	return isnull(@res,0)  
  
  end
  
  
  return 1;
end