create function [dbo].[PR_COMPONENT_MTIDS_2_MTID](@MTID int, @aMode int)  
 returns @res table(ID INT)
as 
begin  
  /* возвращает типы моделей компонент, использующихся в типе моделей*/

  insert into @res (ID)
  select distinct A.BOMMTID 
  from PR_MODELTYPE_BOM A with (nolock)
  where A.MTID = @MTID
  
  insert into @res (ID)
  select distinct B.BOMMTID 
  from PR_MODELTYPE_BOM A with (nolock)
  left join PR_MODELTYPE_BOM_T B with (nolock) on B.VNESHID = A.ID
  where A.MTID = @MTID
    and not exists (select C.ID from @res C where C.ID = B.BOMMTID)
  
  
  return

end