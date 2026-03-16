CREATE function [dbo].[SM_PROTOCOL_BOM](@aMode int, @aID int)
returns nvarchar(max) as 
begin

  declare @res nvarchar(max)
  
  if (@aMode = 1) /* BOM Position  (Spare part Description) */
  begin
     select @res = B.NAME
     from PR_OPERATION_INSTALL A with (nolock)
     left join PR_MODELTYPE_BOM B with (nolock) on B.ID = A.BOMID
     where A.ID = @aID
  end
  else if (@aMode = 2) /* SN */
  begin
     select @res = B.SN
     from PR_OPERATION_INSTALL A with (nolock)
     left join PR_DEVICE B with (nolock) on B.ID = A.PARTID
     where A.ID = @aID
  end
  else if (@aMode = 3) /* Model Name */
  begin
     select @res = C.NAME
     from PR_OPERATION_INSTALL A with (nolock)
     left join PR_DEVICE B with (nolock) on B.ID = A.PARTID
     left join PR_MODELS C with (nolock) on C.ID = B.MODELID
     where A.ID = @aID
  end
  else if (@aMode = 4) /* Model Code */
  begin
     select @res = C.CODE
     from PR_OPERATION_INSTALL A with (nolock)
     left join PR_DEVICE B with (nolock) on B.ID = A.PARTID
     left join PR_MODELS C with (nolock) on C.ID = B.MODELID
     where A.ID = @aID
  end
  else if (@aMode = 1000) /*  REMOVED BOM Position*/
  begin
     select @res = B.NAME
     from PR_OPERATION_UNINSTALL AA with (nolock)
     left join PR_OPERATION_INSTALL A with (nolock) on A.ID = AA.INSTALLROWID
     left join PR_MODELTYPE_BOM B with (nolock) on B.ID = A.BOMID
     where AA.ID = @aID
  end
  else if (@aMode = 1002) /* REMOVED SN */
  begin
     select @res = B.SN
     from PR_OPERATION_UNINSTALL AA with (nolock)
     left join PR_OPERATION_INSTALL A with (nolock) on A.ID = AA.INSTALLROWID
     left join PR_DEVICE B with (nolock) on B.ID = A.PARTID
     where AA.ID = @aID
  end
  else if (@aMode = 1003) /* REMOVED Model Name */
  begin
     select @res = C.NAME
     from PR_OPERATION_UNINSTALL AA with (nolock)
     left join PR_OPERATION_INSTALL A with (nolock) on A.ID = AA.INSTALLROWID
     left join PR_DEVICE B with (nolock) on B.ID = A.PARTID
     left join PR_MODELS C with (nolock) on C.ID = B.MODELID
     where AA.ID = @aID
  end
  else if (@aMode = 1004) /* REMOVED Model Code */
  begin
     select @res = C.CODE
     from PR_OPERATION_UNINSTALL AA with (nolock)
     left join PR_OPERATION_INSTALL A with (nolock) on A.ID = AA.INSTALLROWID
     left join PR_DEVICE B with (nolock) on B.ID = A.PARTID
     left join PR_MODELS C with (nolock) on C.ID = B.MODELID
     where AA.ID = @aID
  end
  
  
  
  return @res
  
end