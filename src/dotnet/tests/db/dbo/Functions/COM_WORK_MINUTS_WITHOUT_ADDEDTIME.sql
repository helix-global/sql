create function [dbo].[COM_WORK_MINUTS_WITHOUT_ADDEDTIME] (@dBeg datetime, @dEnd datetime, @whID int, @calendar int, @emplID int)
returns decimal(16,2)
as 
begin
 
    if @whID is null
      return datediff(mi,@dBeg,@dEnd)
 
    declare @workM decimal(16,3);
    
    with 
     allworks    
	  as (select A.DBEG as dbeg, A.DEND as dend from dbo.COM_WORKPERIODS(@dBeg,@dEnd,@calendar,@whID,@emplID) A)
	,result 
	  as (select 
			case when dbeg < @dBeg then @dBeg else dbeg end as dbeg
		   ,case when dend > @dEnd then @dEnd else dend end as dend
			from allworks
		   )
   select @workM = SUM(DATEDIFF(s,A.dbeg,A.dend)) from result A where A.dbeg < A.dend 
   
   set @workM = @workM / 60

   return @workM;

end