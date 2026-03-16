create function [dbo].[PR_OPERATION_BOMITEM_SN](@OperID int, @BomItemID int,@aMode int)
returns nvarchar(100) as 
begin
  declare @resSN nvarchar(100)
  select top 1 @resSN = B.SN 
  from PR_OPERATION_INSTALL A with (nolock)
  left join PR_DEVICE B with (nolock) on B.ID = A.PARTID
  where A.OPERID = @OperID 
    and A.BOMID = @BomItemID
    and B.ID is not null
  return @resSN
end