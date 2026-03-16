CREATE function [dbo].[COM_OVERTIME_MINUTS_BY_DEPARTMENT] (@dBeg datetime, @dEnd datetime, @depID int, @aMode int)
returns decimal(18,2)
as 
begin

   declare @res decimal(18,2)

   if @aMode = 2
   begin
       /*без автоматических */
	   select @res = sum(datediff(minute,M.DBEG,M.DEND))
	   from (
	   select case when A.DBEG < @dBeg then @dBeg else A.DBEG end as DBEG
			 ,case when A.DEND > @dEnd then @dEnd else A.DEND end as DEND
	   from COM_ADDED_WORKTIME A with (nolock)
	   left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLID
	   where B.DEPID = @depID   
		 and A.DBEG <= @dEnd
		 and A.DEND >= @dBeg
		 and isnull(A.AUTOADDEDTIME,0) <> 1
	   ) M
	    
	   return @res;
   
   end


   select @res = sum(datediff(minute,M.DBEG,M.DEND))
   from (
   select case when A.DBEG < @dBeg then @dBeg else A.DBEG end as DBEG
         ,case when A.DEND > @dEnd then @dEnd else A.DEND end as DEND
   from COM_ADDED_WORKTIME A with (nolock)
   left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLID
   where B.DEPID = @depID   
     and A.DBEG <= @dEnd
     and A.DEND >= @dBeg
   ) M
    
   return @res;

end