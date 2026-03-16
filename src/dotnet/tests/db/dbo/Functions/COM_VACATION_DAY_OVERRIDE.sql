CREATE function [dbo].[COM_VACATION_DAY_OVERRIDE](@aID int, @aEmplID int, @aDD date)
returns int as 
begin

  /* 
    в дополнение (!!! именно в дополнение) к COM_VACATION_OVERRIDE
    проверяет что весь день из одной заявки попал в выходной как _полный_ день по другой заявке
  */
  
  declare @res int
  
  IF exists (select A.ID 
             from COM_VACATION A with (nolock, index = IX_COM_VACATION_1) 
             where A.EMPLID = @aEmplID
               and A.S_S in (1000141,2130051)
               and isnull(A.PERIODTYPE,1) = 1 /*когда половина - период не м.б. больше дня*/
               and A.VACATIONTYPE not in (30,80,200) /*эти не м.б. полным днем*/
               and cast(A.DBEG as date) <= @aDD
               and cast(isnull(A.DEND,A.DBEG) as date) >= @aDD
               and A.ID > @aID
           )
  BEGIN         
     return 1
  END           

  return 0
  
end