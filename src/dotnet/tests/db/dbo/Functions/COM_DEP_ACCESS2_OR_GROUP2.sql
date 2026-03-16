create function [dbo].[COM_DEP_ACCESS2_OR_GROUP2](@aDepID int,@aMode int,@aUserID int,@aDate datetime,@aGroupName1 nvarchar(50),@aGroupName2 nvarchar(50),@aGroupName3 nvarchar(50),@aGroupName4 nvarchar(50),@aGroupName5 nvarchar(50))
returns int as 
begin
  if @aGroupName1 is not null or @aGroupName2 is not null or @aGroupName3 is not null or @aGroupName4 is not null or @aGroupName5 is not null
  begin
    if dbo.DEF_USERINGROUP5(@aUserID,@aGroupName1,@aGroupName2,@aGroupName3,@aGroupName4,@aGroupName5) = 1
      return 1
  end
  return dbo.COM_DEP_ACCESS2(@aDepID,@aMode,@aUserID,@aDate)
end