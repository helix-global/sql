create function [dbo].[PR_DEQUIPMENT](@EquipID int, @aN int, @Mode int)
returns nvarchar(100) as 
begin
  declare @SN nvarchar(100);
  declare @Code nvarchar(100);
   
  select top 1 @SN = B.SN
              ,@Code = C.CODE
  from EQ_EQUIPMENT_LINKED A with (nolock) 
  left join EQ_EQUIPMENT B with (nolock) on B.ID = A.LINKED_EQID
  left join EQ_MODELS C with (nolock) on C.ID = B.EQMODELID 
  where A.VNESHID = @EquipID
    and (select COUNT(*) from EQ_EQUIPMENT_LINKED N where N.VNESHID = @EquipID and N.ID < A.ID) = @aN - 1
   
  if @Mode = 1
    return @SN

  if @Mode = 2
    return @Code
     
  return null 
   
end