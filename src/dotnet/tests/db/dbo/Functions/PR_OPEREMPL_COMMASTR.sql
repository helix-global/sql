
CREATE function [dbo].[PR_OPEREMPL_COMMASTR](@aOperID int)
returns nvarchar(1024)
as
begin

  declare @defUserID int
  select @defUserID = A.USERINPROGRESS from PR_OPERATION A with (nolock) where A.ID = @aOperID
  if @defUserID is not null
  begin   
     declare @oneR nvarchar(250)
     select @oneR = A.FULLNAME from DEF_USERS A with (nolock) where A.ID = @defUserID
     return @oneR;
  end

  declare @res nvarchar(1024)
  set @res = '';
  select @res = @res + D.NAME + ', '
  from PR_OPERATION A with (nolock)
  left join PR_OPERATIONS B on B.ID = A.OPERTYPEID
  left join PR_EMPL_TO_OPERGR C on C.GROUPID = B.OPERGRID
  left join COM_EMPLOYEE D on D.ID = C.EMPLOYEEID
  where A.ID = @aOperID
    
  declare @reslen int
  set @reslen = len(@res)
  if @reslen > 2
    set @res = SUBSTRING(@res,1,@reslen-1)
    
  return @res;
end;