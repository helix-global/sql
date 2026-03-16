CREATE function [dbo].[DEF_USERID2](@aDate datetime)
returns int as 
begin
  declare @res int
  select @res = ID from DEF_USERS with (nolock) where upper(LOGINNAME)=upper(ORIGINAL_LOGIN()) and isnull(ISGROUP,0) = 0
  if @res is null 
     select @res = ID from DEF_USERS with (nolock) where upper(LOGINNAME2)=upper(ORIGINAL_LOGIN()) and isnull(ISGROUP,0) = 0
  
  declare @shAccID int
  select @shAccID = A.ID from COM_SHARED_ACCOUNTS A with (nolock) where A.ACCOUNTID = @res 
  
  if @shAccID is not null
  begin
     
     declare @emplID int
     select top 1 @emplID = A.EMPLOYEEID from COM_SHACCOUNT_S A with (nolock) 
     where A.ACCOUNTID = @shAccID
       and A.DBEG < @aDate
       and dateadd(day,1,A.DEND) > @aDate 
       and A.S_S = 1000066
     
     if (@emplID is not null)
     begin
       select top 1 @res = B.ID from DEF_USERS B with (nolock) where B.EMPLOYEEID = @emplID
     end
     else
       return -1
     
  end
  
  return @res
end