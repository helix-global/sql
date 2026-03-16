create function [dbo].[COM_WORKP_MINUTS_BY_DEPARTMENT] (@dBeg datetime, @dEnd datetime, @depID int, @aMode int)
returns decimal(18,2)
as 
begin

   declare @res decimal(18,2)

   select @res = sum(datediff(minute,B.DBEG,B.DEND))
   from COM_EMPLOYEE A with (nolock)
   left join COM_WORKTIME BB with (nolock) on BB.DEPID = A.DEPID and isnull(BB.WTDEFAULT,0) = 1
   left join COM_WORKTIME BB2 with (nolock) on BB2.ID = A.PERSONALWT
   cross apply dbo.COM_WORKPERIODS3 (@dBeg,@dEnd,ISNULL(BB2.CALENDAR,BB.CALENDAR),ISNULL(A.PERSONALWT,BB.ID),A.ID) B
   where A.DEPID = @depID   
    
   return @res;

end