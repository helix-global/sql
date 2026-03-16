CREATE function [dbo].[PR_SERVMAPMTID_4DEVICES](@aItemIDs nvarchar(max), @aServMapMTID int)
returns int as 
begin
  /*  
  при подборе сервисных карт в сервисный заказ проверяет,
  тип модели карты соответствует типу моделей всех изделий (если они все одного типа моделей)
  */
   
  if (@aItemIDs is null)
    return 1
    
  if len(ltrim(@aItemIDs)) = 0
    return 1
    
  declare @itemsMTID table (MTID int)
  
  insert into @itemsMTID (MTID)
  select distinct B.TYPEID
  from PR_DEVICE A with (nolock)
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID
  where A.ID in (select ID from dbo.COM_STR2TABLE_INT(@aItemIDs))

  if @@rowcount = 1
  begin
     if @aServMapMTID = (select MTID from @itemsMTID)
        return 1
  end
   
  return 0 
  
end