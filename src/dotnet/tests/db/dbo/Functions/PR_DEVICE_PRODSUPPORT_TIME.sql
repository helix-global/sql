create function dbo.PR_DEVICE_PRODSUPPORT_TIME (@DeviceID int)
returns @res table (QUALIFICATION int, ELAPSED decimal(12,2))
as 
begin

  insert into @res (QUALIFICATION, ELAPSED)
  select A.QUALIFICATION, sum(isnull(A.ADDVALUE,0))
  from PR_DEVICE D
  left join PR_REV_ADD_TIMES A with (nolock) on A.REVID=D.REVID
  where D.ID=@DeviceID
    and A.PRODSUPPORT=1
  group by A.QUALIFICATION

  return

end