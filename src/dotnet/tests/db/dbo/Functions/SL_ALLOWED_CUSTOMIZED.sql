CREATE function [dbo].[SL_ALLOWED_CUSTOMIZED] (@aUserID int,@aMode int)
returns @res table (ID int)
as 
begin

  declare @Allowed int
  select @Allowed = dbo.DEF_USERINGROUP5(@aUserID,'CNFG',null,'ADM',null,null)

  if @aMode = 1 /* модели */
  begin
  
	  insert into @res (ID)
	  select distinct A.ID
	  from SL_MODELS A with (nolock)
	  left join COM_CUST_GROUP_T B with (nolock) on B.VNESHID = A.CUSTOM4GROUP
	  left join PR_NAV_ALLOWED_CUSTOMERS C with (nolock) on C.CUSTID = B.CUSTID
	  left join PR_NAV_ALLOWED_CUSTOMERS C2 with (nolock) on C2.CUSTID = A.CUSTOM4ID
	  where A.PRTYPE <> 2 or C.USERID = @aUserID or @Allowed = 1 or C2.USERID = @aUserID

	  insert into @res (ID)
	  select distinct A.ID
	  from SL_MODELS_V A with (nolock)
	  left join COM_CUST_GROUP_T B with (nolock) on B.VNESHID = A.CUSTOM4GROUP
	  left join PR_NAV_ALLOWED_CUSTOMERS C with (nolock) on C.CUSTID = B.CUSTID
	  left join PR_NAV_ALLOWED_CUSTOMERS C2 with (nolock) on C2.CUSTID = A.CUSTOM4ID
	  where A.PRTYPE <> 2 or C.USERID = @aUserID or @Allowed = 1 or C2.USERID = @aUserID

	  
  end
  else if @aMode = 2 /* опции */
  begin
  
	  insert into @res (ID)
	  select distinct A.ID
	  from SL_OPTIONS A with (nolock)
	  left join COM_CUST_GROUP_T B with (nolock) on B.VNESHID = A.CUSTOM4GROUP
	  left join PR_NAV_ALLOWED_CUSTOMERS C with (nolock) on C.CUSTID = B.CUSTID
	  left join PR_NAV_ALLOWED_CUSTOMERS C2 with (nolock) on C2.CUSTID = A.CUSTOM4ID
	  where A.PRTYPE <> 2 or C.USERID = @aUserID or @Allowed = 1 or C2.USERID = @aUserID


	  insert into @res (ID)
	  select distinct A.ID
	  from SL_OPTIONS_V A with (nolock)
	  left join COM_CUST_GROUP_T B with (nolock) on B.VNESHID = A.CUSTOM4GROUP
	  left join PR_NAV_ALLOWED_CUSTOMERS C with (nolock) on C.CUSTID = B.CUSTID
	  left join PR_NAV_ALLOWED_CUSTOMERS C2 with (nolock) on C2.CUSTID = A.CUSTOM4ID
	  where A.PRTYPE <> 2 or C.USERID = @aUserID or @Allowed = 1 or C2.USERID = @aUserID
	  
  end
  else if @aMode = 10 /* клиенты */
  begin

	  insert into @res (ID)
	  select distinct A.ID
	  from COM_CUSTOMER A with (nolock)
	  left join PR_NAV_ALLOWED_CUSTOMERS C with (nolock) on C.CUSTID = A.ID
	  where C.USERID = @aUserID or @Allowed = 1
  
  end
  
  return

end