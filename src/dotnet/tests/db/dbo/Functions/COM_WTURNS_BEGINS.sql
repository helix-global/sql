CREATE function [dbo].[COM_WTURNS_BEGINS] (@whID int, @aMode int)
returns @res table (TFROM time, WTURN int, WTURNLEN int)
as 
/*
Выдает времена начал рабочих смен. 
!Смены, начинающиеся после полуночи не учитываются как смены предыдущего дня, считается что таких смен не д.б.

При @aMode = 1 таблица дополняется временами начал вторых половин смен. (нужно, чтобы программа не ошибалась, если человек берет «полдня» отпуска)

*/
begin
    insert into @res (TFROM, WTURN)
	select cast(A.TFROM as time), A.WTURN
	from COM_WORKTIME_BR A with (nolock)
	where A.VNESHID = @whID
	  and A.ID = (select top 1 B.ID 
					from COM_WORKTIME_BR B with (nolock)
				   where B.VNESHID = A.VNESHID 
					 and B.WTURN = A.WTURN 
					order by cast(B.TFROM as time))
					
    if (@aMode = 1)
    begin
    
      update @res set WTURNLEN = 8*60
    
      insert into @res (TFROM, WTURN, WTURNLEN)
      select  dateadd(minute,(WTURNLEN /2),A.TFROM)
             , A.WTURN
             , A.WTURNLEN
        from @res A
    
    end				
    	
	return				
end