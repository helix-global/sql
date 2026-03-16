CREATE function [dbo].MSG_DEP_HEADS_ADDR(@aDepID int, @aMode int)
returns nvarchar(1024) as 
begin

  declare @res nvarchar(1024) = '';
  
  select @res = @res + case when len(@res) > 0 then '; ' else '' end + B.EMAIL 
  from DEF_USERS A with (nolock)
  left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLOYEEID
  where B.DEPID = @aDepID
    and dbo.DEF_USERINGROUP7(A.ID,'DH&VICE') = 1
    and B.EMAIL is not null
 
  return @res;
  
end