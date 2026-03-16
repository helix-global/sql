create function [dbo].[EQ_EQUIPMENT_CHILDSLINKED] (@aEqID int, @aMode int)
returns @res table (ID int)
as 
begin

  insert into @res(ID) values (@aEqID)

  
 
    insert into @res(ID) 
    select A.LINKED_EQID 
    from EQ_EQUIPMENT_LINKED A with (nolock)
    where A.VNESHID = @aEqID
      

  return
 
end