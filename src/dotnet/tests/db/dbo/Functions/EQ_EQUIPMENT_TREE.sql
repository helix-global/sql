create function [dbo].[EQ_EQUIPMENT_TREE] (@aEqID int)
returns @res table (ID int)
as 
begin

  insert into @res(ID) values (@aEqID)

  

  /* вверх */
  while 1=1
  begin
  
    insert into @res(ID) 
    select A.LINKED_EQID 
    from EQ_EQUIPMENT_LINKED A with (nolock)
    where A.VNESHID in (select ID from @res)
      and A.LINKED_EQID not in (select ID from @res)
      
    if @@rowcount = 0 break;
       
  end  
  
  /* вниз */
  while 1=1
  begin
  
    insert into @res(ID) 
    select A.VNESHID 
    from EQ_EQUIPMENT_LINKED A with (nolock)
    where A.LINKED_EQID in (select ID from @res)
      and A.VNESHID not in (select ID from @res)
      
    if @@rowcount = 0 break;
       
  end  

  return
 
end