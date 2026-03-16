CREATE function dbo.PR_DEVICE_PRODSUPPORT_TIME_SUGG (@DeviceID int, @SuggestionID int)
returns @res table (QUALIFICATION int, ELAPSED decimal(12,2))
as 
begin

  insert into @res (QUALIFICATION, ELAPSED)
  select A.QUALIFICATION, sum(isnull(S.ADDVALUE, isnull(A.ADDVALUE,0)))
  from PR_DEVICE D
  left join PR_REV_ADD_TIMES A with (nolock) on A.REVID=D.REVID and A.PRODSUPPORT=1
  left join PR_REV_SUPP_ADD_TIMES_SUGGEST_T S on S.REVID=D.REVID and (A.ID is null or S.QUALIFICATION=A.QUALIFICATION) and S.VNESHID=@SuggestionID and isnull(S.ISCHECKED,0)=1
  where D.ID=@DeviceID
  group by A.QUALIFICATION

  return

end