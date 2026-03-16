CREATE function [dbo].[PR_SO_NEED_STATE](@SOrderID int)
returns int as 
begin

/*
1000042	In production[RU=В производстве
1000043	Completed[RU=Производство завершено
1000072	Shipped[RU=Отгружен
1000083	Prepared[RU=Подготовлен
1000135	Canceled[RU=Отменен
*/
  /*нет изделий вообще - статус: создан */
  if not exists (select A.ID 
               from PR_DEVICE A with (nolock)
              where A.SORDERID = @SOrderID
              )
    return 1
    
  /*declare @SOclosingMode int*/  /* 1 - не учитывать что не хватает изделий (KB375)*/
  /*
  select @SOclosingMode = isnull(B.SOCLOSEMODE,0)
  from PR_SUPPLY A with (nolock) 
  left join COM_DEPARTMENTS B with (nolock) on B.ID = A.DEPARTMENTID
  where A.ID = @SOrderID
  
  set @SOclosingMode = 0  
  */

  /*есть заказанная модель и количество, но прикреплено недостаточное количество изделий - статус в производстве */
  declare @ModelID int
  declare @Qty decimal(18,4)
  declare @QtyRest decimal(18,4)
  select @ModelID = A.MODELID
        ,@Qty = A.QTY
        ,@QtyRest = dbo.PR_SUPPLY_REST_QTY(A.ID, A.QTY)
    from PR_SUPPLY A with (nolock) 
   where A.ID = @SOrderID
   
  if @ModelID is not null and @Qty is not null
  begin
     if @QtyRest > 0 /*and isnull(@SOclosingMode,0) <> 1*/ return 1000042
  end

  /*нет изделий кроме отмененных - статус: отменен */
  if not exists (select A.ID 
               from PR_DEVICE A with (nolock)
              where A.SORDERID = @SOrderID
                and A.S_S <> 1000101 /*canceled*/
                )
    return 1000135

  /*нет изделий кроме отмененных и shipped - статус: shipped */
  if not exists (select A.ID 
               from PR_DEVICE A with (nolock)
              where A.SORDERID = @SOrderID
                and A.S_S <> 1000101 /*canceled*/
                and A.S_S <> 1000010 /*shipped*/
                )
    return 1000072

  /*есть изделия у которых производство не завершено и они не отменены */
  if exists (select A.ID 
               from PR_DEVICE A with (nolock)
              where A.SORDERID = @SOrderID 
                and A.S_S <> 1000101 /*canceled*/
                and A.COMPLETED_DT is null )
  begin
     /* нет изделий кроме отмененных и подготовленных - статус: подготовлен*/
     if not exists (select A.ID 
               from PR_DEVICE A with (nolock)
              where A.SORDERID = @SOrderID 
                and A.S_S <> 1000101 /*canceled*/
                and A.S_S <> 1000057 /*prepared*/)
       return 1000083 /*prepared*/
     else /*иначе - в производстве*/
       return 1000042 /*in production*/
  end
  else /* нет изделий у которых производство не завершено*/
  begin
  
     if exists (select A.ID 
               from PR_DEVICE A with (nolock)
              where A.SORDERID = @SOrderID 
                and A.S_S = 1000022 /*prod.compl*/)
         return 1000043       

     
     /* все отгружены */
     if not exists (select A.ID 
               from PR_DEVICE A with (nolock)
              where A.SORDERID = @SOrderID 
                and A.S_S <> 1000101 /*canceled*/
                and A.SHIPPED_DT is null)
       return 1000072 /*shipped*/
     else     
       return 1000043 /*completed*/
  end
  return 1

end