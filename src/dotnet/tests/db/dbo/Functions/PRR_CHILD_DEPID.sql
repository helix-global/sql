CREATE function [dbo].[PRR_CHILD_DEPID](@aParentDepID int,@aMode int)
returns @res table (ID int) as 
begin
/* 
   функция выдает список дочерних подразделений в целях отчетности
   чтобы в статистике оказывались "значимые" изделия,
   например по ILA нужно брать статистику по лазерам, и не учитывать дочерние HPLC
   по BOC подгруппы BOC-Coll BOC-Conn BOC-ISO BOC-BSw без других и т.п. 
   можно модифицировать под потребности, например вводя новые режимы @aMode
 */

  insert into @res(ID)
  values (@aParentDepID)
  
  if @aMode = 1
  begin
    
     if @aParentDepID = 89 /*EMA*/
     begin
       delete from @res
       insert into @res(ID) values (206) /*EMA-PL*/
       insert into @res(ID) values (209) /*EMA-YL*/
       insert into @res(ID) values (207) /*EMA-YM*/
     end
     else if @aParentDepID = 82 /*BOC*/
     begin
       delete from @res
       insert into @res(ID) values (213) /*BOC-Coll*/
       insert into @res(ID) values (212) /*BOC-Conn*/
       insert into @res(ID) values (214) /*BOC-ISO*/
       insert into @res(ID) values (216) /*BOC-BSw*/
     end
     else
     begin
       insert into @res(ID)
       select ID from dbo.COM_GETCHILD_DEPARTMENTS(@aParentDepID)
     end
  
  end
  else if @aMode = 100
  begin
    insert into @res(ID)
    select ID from dbo.COM_GETCHILD_DEPARTMENTS(@aParentDepID)
  end
  
    
  return 
end