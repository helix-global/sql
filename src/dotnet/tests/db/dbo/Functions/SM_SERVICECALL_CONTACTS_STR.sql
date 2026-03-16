create function [dbo].[SM_SERVICECALL_CONTACTS_STR](@aID int, @aMode int)
returns nvarchar(max) as 
begin
/*
@aMode
 1 - внешние
 2 - внутренние
*/   
  declare @res nvarchar(max)

  if @aMode = 1 
  begin
    select @res = isnull(@res,'') + B.NAME +'; '
    from SM_SERVICE_CALL_T A with (nolock)
    left join COM_CUST_CONTACTS B with (nolock) on B.ID = A.CNTID
    where A.VNESHID = @aID
  end


  if @aMode = 2 
  begin
    select @res = isnull(@res,'') + isnull(A.NAME,A.EMAIL) +'; '
    from SM_SERVICE_CALL_TINT A with (nolock)
    where A.VNESHID = @aID
  end
   
  return @res
  
end