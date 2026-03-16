CREATE function [dbo].[PR_IS_FREE_REPAIR](@OperID int, @ParentOperID int, @FreeTR int)
returns int  as 
begin

  if @FreeTR = 1
	return 1

  if @ParentOperID is null
    return 0
  
  declare @freeTrouble int
  
  select top 1 @freeTrouble = A.ID 
  from PR_OPERATION A with (nolock) 
  left join PR_OPERATIONS B with (nolock) on B.ID = A.OPERTYPEID
 where A.ID = @ParentOperID
   and B.OPERTYPE = 1 /*troublesh*/
   and A.FREETR = 1

  if @freeTrouble is not null
     return 1
  
  return 0
  
end