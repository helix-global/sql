create function [dbo].[PR_CHECK_SN2](@SN nvarchar(50), @DeviceID int, @ModelID int)
returns int as 
begin

  declare @mtid int
  declare @WholeTypeUnique int
  
  select @mtid = A.TYPEID
        ,@WholeTypeUnique = ISNULL(B.SNUNIQUE,0)
    from PR_MODELS A with (nolock) 
    left join PR_MODELTYPE B with (nolock) on B.ID = A.TYPEID 
   where A.ID = @ModelID
 
  if @SN = '0' or @SN = '-'
    return 0

  if @WholeTypeUnique <> 1
    return 0
    
  if exists (select A.ID 
               from PR_DEVICE A 
               left join PR_MODELS B with (nolock) on B.ID = A.MODELID
              where B.TYPEID = @mtid
                and A.ID <> @DeviceID
                and A.SN = @SN )
                return 1
  
  
  return 0

end