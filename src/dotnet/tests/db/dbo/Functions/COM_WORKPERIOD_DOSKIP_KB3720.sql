create function [dbo].[COM_WORKPERIOD_DOSKIP_KB3720] (@wDD date, @wTurn int, @whID int, @emplid int )
returns int
as
begin
/*
KB3720
сделана для отброса периодов работы, которые не нужно проверять при вводе переработки
возвращает 1 если этот период не проверять
принцип такой: если в графике сотрудника 3 смены (а это значит что заранее не известно в какую он будет работать в будущем)
 и период принадлежит той смене, которая не определена в COM_TURNS, то такой 
 период возвращает 1 и переработка в этом периоде не запрещается
если в графике только одна смена, то ни в какую другую сотрудник не попадет и переработка при попадании 
 на этот период запрещается
TODO для 2-ух смен считать как для 3-х ?
*/
 declare @turnsCount int
 select @turnsCount = count(distinct A.WTURN) from COM_WORKTIME_BR A with(nolock) where A.VNESHID = @whID
 
 if @turnsCount > 2
 begin
   if not exists (select JJ.ID 
                    from COM_TURNS JJ with(nolock) 
                   where JJ.EMPLID = @emplid 
                     and JJ.DD = @wDD 
                     and JJ.WTURN = @wTurn)
   begin
     return 1
   end                  
                     
 end

 return 0
 
end