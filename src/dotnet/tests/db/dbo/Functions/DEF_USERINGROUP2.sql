CREATE function [dbo].[DEF_USERINGROUP2](@aUserID int,@aGroupID int,@aDate datetime,@ReturnIfInGr int)
returns int as 
begin

  if @ReturnIfInGr = 0
    return 0

  if @aGroupID = 10 /* All */
    return @ReturnIfInGr;

  declare @tmp int
  select @tmp = A.GROUPID from DEF_USERSTOGROUP A with (nolock)
  where A.USERID = @aUserID and A.GROUPID = @aGroupID and (A.DCLS is null or A.DCLS >= cast(@aDate as date));

  if (@tmp = @aGroupID)
    return @ReturnIfInGr;

  if exists (select B.ID 
               from DEF_USERSTOGROUP B with (nolock) 
              where B.USERID = @aGroupID
                and (B.DCLS is null or B.DCLS >= cast(@aDate as date))
                and dbo.DEF_USERINGROUP(@aUserID,B.GROUPID,@aDate) = 1
             )
    return @ReturnIfInGr;          


  return 0;
end