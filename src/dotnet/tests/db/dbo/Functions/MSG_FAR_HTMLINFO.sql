create function [dbo].[MSG_FAR_HTMLINFO](@aFarID int,@aMode int)
returns nvarchar(max) 
as
begin

  declare @res nvarchar(max)

  select @res = 'SN: <b>'+isnull(A.SN,'NA')+'</b><br>'
               +'Model: <b>'+isnull(B.NAME,'NA')+'</b><br>'
               +'Model Code: <b>'+isnull(B.CODE,'NA')+'</b><br>'
  from FC_REPORT A with (nolock)
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID
  left join COM_DEPARTMENTS C with (nolock) on C.ID = B.DEPID
  where A.ID = @aFarID
    
  return @res
end;