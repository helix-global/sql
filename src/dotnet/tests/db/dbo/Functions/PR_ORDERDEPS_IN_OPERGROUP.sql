create function [dbo].[PR_ORDERDEPS_IN_OPERGROUP](@UserID int)  
 returns @res table(ID INT)
as 
begin  
  
  /*
  функция сделана для использования в фильтре выбора подразделения 
  при указании подразделения заказа в привязке пользователя к группе операции
  
  помимо разрешенных подразделений прибавляются подразделения которые указаны как сервисные подразделения в своих типах моделей 
  
  */
  
  /* 1 типовая проверка  */
  insert into @res (ID)
  select ID from dbo.COM_ACCESS_DEPARTMENTS(@UserID,1,getdate()) 
  
  /* 2 добавка с сервисных подразделений */
  insert into @res (ID)
  select A.DEPID 
  from PR_SERVICE_DEPARTMENTS A with (nolock)
  left join PR_MODELTYPE B with (nolock) on B.ID = A.MTID
  where B.DEPARTMENTID in (select ID from @res)
  
  
  
  return

end