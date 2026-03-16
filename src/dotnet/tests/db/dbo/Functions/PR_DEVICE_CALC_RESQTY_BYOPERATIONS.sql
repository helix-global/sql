CREATE function [dbo].[PR_DEVICE_CALC_RESQTY_BYOPERATIONS](@DeviceID int, @aMode int)
returns int as 
begin
  /* 
  считает итоговое количество частей в изделии для типа учета 1 (By SN + Qty (new operation fo rest) 
  если в какой-нибудь операции результат увеличен по отношению ко входу - то сумма по д.б прибавлена к изделию 
  */
  declare @res int
  
  if (@aMode = 1)
  begin

	  select @res = sum(case when coalesce(A.PREP_RESULT,A.Q_IN,1) > isnull(A.Q_IN,1) then coalesce(A.PREP_RESULT,A.Q_IN,1)-isnull(A.Q_IN,1) else 0 end)
	  from PR_OPERATION A with (nolock)
	  where A.DEVICEID = @DeviceID
		and not exists (select B.ID from PR_OPERATION B with (nolock) where B.DEVICEID = A.DEVICEID and B.PARENTID = A.ID)
		and A.COMPLETED_DT is not null
		and A.S_S <> 1000023
  
  end
  
  return @res;  

end