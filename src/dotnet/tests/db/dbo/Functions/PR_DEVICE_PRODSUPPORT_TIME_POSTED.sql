create function dbo.PR_DEVICE_PRODSUPPORT_TIME_POSTED (@DeviceID int)
returns @res table (QUALIFICATION int, ELAPSED decimal(12,2))
as 
begin

  insert into @res (QUALIFICATION, ELAPSED)
  select S.QUALIFICATION, sum(isnull(S.ELAPSED,0))
  from PR_DEVICE_PROD_SUPP S
  where S.DEVICEID=@DeviceID
  group by S.QUALIFICATION

  return

end