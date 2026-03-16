CREATE function [dbo].[PR_MTYPES_4_BOMITEM](@BomID int, @aMode int)  
 returns @res table(ID INT)
as 
begin  
  
  insert into @res (ID)
  select A.BOMMTID from PR_MODELTYPE_BOM A with (nolock) where A.ID = @BomID and A.BOMMTID is not null
  union 
  select B.BOMMTID from PR_MODELTYPE_BOM_T B with (nolock) where B.VNESHID = @BomID
    
  if @aMode = 1 and @BomID > 0
  begin
     
     if not exists (select ID from @res)
     insert into @res
     select ID from PR_MODELTYPE
  
  end 
    
  return

end