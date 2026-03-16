CREATE function [dbo].[PR_DEVICE_PRODSUPPORT_TIME_POSTED2] (@DeviceID int)
returns @res table (QUALIFICATION int, ELAPSED decimal(12,2))
as 
begin

  /*v.2 KB3325 возвращает то-же что v.1, но не именно 'posted', а просто записанные при завершении операции 
    чтобы не поменять отчеты по тем у кого "постинги" давно были по версии 1 - сначала ищется по-новому 
    и только если данных нет - ищется по старому
  */

  insert into @res (QUALIFICATION, ELAPSED)
  select S.QUALIFICATION, sum(isnull(S.ELAPSED,0))
  from PR_DEVICE_PROD_SUPP_H S
  where S.DEVICEID=@DeviceID
  group by S.QUALIFICATION
  
  if @@rowcount = 0
  begin

	  insert into @res (QUALIFICATION, ELAPSED)
	  select S.QUALIFICATION, sum(isnull(S.ELAPSED,0))
	  from PR_DEVICE_PROD_SUPP S
	  where S.DEVICEID=@DeviceID
	  group by S.QUALIFICATION
  
  end
  

  return

end