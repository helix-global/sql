CREATE function [dbo].[PR_OPERATIONS_EDITABLE](@aMTID int,@aDepID int,@aMode int,@aUserID int,@aDate datetime)
returns int as 
begin
  
  declare @result int
  set @result = dbo.COM_DEP_ACCESS(null,@aDepID,@aMode,@aUserID,@aDate)
  if @result = 1
    return @result
    
  if dbo.DEF_USERINGROUP7(@aUserID, 'DES') = 1
  begin
    
    if exists (
		select J.MTID
		from SM_PERM2MT J with (nolock)
		where J.DEPID = dbo.COM_USER_DEPARTMENT(@aUserID)
		  and J.MTID = @aMTID
		  and J.DEPID = @aDepID  /*только свои формы !*/
		  and J.ALLOW_FORMSDES = 1
    )
    set @result = 1
  
  end   

  return @result;
end