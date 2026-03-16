create function [dbo].FC_ADDEDPARAMBYNAME(@aMtID int,@aParamName nvarchar(50))
returns int as 
begin
  declare @res int
  select top 1 @res = A.ID from FC_FAILUREPARAMS A with(nolock) where A.MTID = @aMtID and A.NAME = @aParamName
  return @res  
end