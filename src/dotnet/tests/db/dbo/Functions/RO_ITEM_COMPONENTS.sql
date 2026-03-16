CREATE function [dbo].[RO_ITEM_COMPONENTS](@aID int,@aMTID int)
returns @res table (ID int) as 
begin

  insert into @res (ID)
  select A.PARTID
  from PR_OPERATION_INSTALL A with (nolock) 
  left join PR_OPERATION B with (nolock) on B.ID = A.OPERID
  where B.DEVICEID = @aID
    and dbo.PR_UNINSTALL_ID(A.ID) is null
    and (B.S_S IN (1000013, 1000019, 1000038, 1000116))

  insert into @res (ID)
  select B.ID
  from @res A
  outer apply dbo.RO_ITEM_COMPONENTS(A.ID,@aMTID) B
  
  delete from @res
  where (select B.TYPEID from PR_MODELS B with (nolock) where B.ID = (select D.MODELID from PR_DEVICE D with (nolock) where D.ID = "@res".ID)) <> @aMTID
  
  return

end