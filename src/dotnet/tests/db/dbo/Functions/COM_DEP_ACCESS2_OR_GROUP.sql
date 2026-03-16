create function [dbo].[COM_DEP_ACCESS2_OR_GROUP](@aDepID int,@aMode int,@aUserID int,@aDate datetime,@aGroupName nvarchar(50))
returns int as 
begin
  if @aGroupName is not null
  begin
    if dbo.DEF_USERINGROUP4(@aUserID,@aGroupName,@aDate) = 1
      return 1
  end
  return dbo.COM_DEP_ACCESS2(@aDepID,@aMode,@aUserID,@aDate)
end