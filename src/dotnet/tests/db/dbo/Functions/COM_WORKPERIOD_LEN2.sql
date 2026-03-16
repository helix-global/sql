CREATE function [dbo].[COM_WORKPERIOD_LEN2](@whID int, @mode int)
returns int as 
begin
   /* возвращает длину периода из рабочего графика в минутах*/

   declare @res int
   
   declare @baseDate datetime = '20200101'
   

   select @res = sum(datediff(minute,TFROM,TTO))   
   from (
   select  @baseDate + cast(cast(A.TFROM as time) as datetime) as TFROM
          ,@baseDate + cast(cast(A.TTO as time) as datetime) + case when /*datepart(hour,A.TTO) < 3*/cast(A.TTO as time) < cast(A.TFROM as time) then 1 else 0 end as TTO
   from COM_WORKTIME_BR A with (nolock)
   where A.VNESHID = @whID
     and A.WTURN = (select min(B.WTURN) from COM_WORKTIME_BR B with (nolock) where B.VNESHID = A.VNESHID)
   )M
   
   if @mode = 1
      set @res = isnull(@res,60*8)
     
   return @res
end