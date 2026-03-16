create function [dbo].[LN_SKIPPINGS_COUNT](@aCardID int)
returns int as 
begin
  
  declare @res int
  
  select @res = count(*)
  from (
  select distinct B.WEEKID,B.DAY
  from LN_SKIPPING_CARDS A with (nolock)
  left join LN_SKIPPING B with (nolock) on B.ID = A.VNESHID
  where A.CARDID = @aCardID
  ) M
  
  return null
end