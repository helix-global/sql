CREATE function [dbo].[PR_USEDMODELTYPES2](@aMTID int,@aMode int)
returns @res table (ID int) as 
begin

  insert into @res (ID)
  select distinct A.BOMMTID
  from PR_MODELTYPE_BOM A with (nolock)
  where A.MTID = @aMTID

  insert into @res (ID)
  select B.BOMMTID 
  from PR_MODELTYPE_BOM A with (nolock)
  left join PR_MODELTYPE_BOM_T B with (nolock) on B.VNESHID = A.ID
  where A.MTID = @aMTID
	and not exists (select GG.ID from @res GG where GG.ID = B.BOMMTID )
  
   /*TODO рекурсию */

  
  return

end