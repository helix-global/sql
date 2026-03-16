create function [dbo].[DEF_RELATED_ENTITIES](@ClassOID int, @ClassID int)  
 returns @res table(OID int)
as 
begin  

 
  
  insert into @res (OID) 
  select A.ENTITYOID 
  from DEF_CLASSES A with (nolock)
  where A.OID = @ClassOID
    or (@ClassOID is null and A.ID = @ClassID)
  
  
  declare @i int = 0
  while (@i < 20)
  begin
    
    insert into @res (OID) 
    select A.OID 
    from DEF_ENTITY A with (nolock)
    where A.MASTEROID in (select OID from @res)
    
    if @@rowcount = 0
      break
    
    set @i = @i + 1
  end
  
return

end