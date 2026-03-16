CREATE function dbo.PR_OPERATION_FORMS_WHERE_HAS_CONTROL (@DepID int, @ControlType nvarchar(20), @Link nvarchar(2), @LinkGID nvarchar(16))
returns @res table (ID int)
as 
begin

  insert into @res (ID)
  select A.ID 
  from PR_OPERATIONS A with (nolock)
  where (@DepID is null or A.DEPID in (select ID from dbo.COM_DEPARTMENTS_BY_PARENT_ID(@DepID)))
    and
    (
       ((@Link is null     and @LinkGID is null)     and cast(FORMXML as xml).exist('/Form/Item[@Type=sql:variable("@ControlType")]')=1)
    or ((@Link is not null and @LinkGID is null)     and cast(FORMXML as xml).exist('/Form/Item[@Type=sql:variable("@ControlType")][@Link=sql:variable("@Link")]')=1)
    or ((@Link is null     and @LinkGID is not null) and cast(FORMXML as xml).exist('/Form/Item[@Type=sql:variable("@ControlType")][@LinkGID=sql:variable("@LinkGID")]')=1)
    or ((@Link is not null and @LinkGID is not null) and cast(FORMXML as xml).exist('/Form/Item[@Type=sql:variable("@ControlType")][@Link=sql:variable("@Link")][@LinkGID=sql:variable("@LinkGID")]')=1)
    )
    
  return

end