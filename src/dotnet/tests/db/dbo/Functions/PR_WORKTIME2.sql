CREATE FUNCTION [dbo].[PR_WORKTIME2]
(
	@WorkTimeID int, @Now datetime
)
RETURNS int
AS
BEGIN
   
declare @dBeg datetime
declare @dEnd datetime
declare @emplID int
declare @wtID int
declare @Calendar int 
declare @res int

select @dBeg = A.DBEG, @dEnd = ISNULL(A.DEND,@Now), @emplID = A.EMPID
from PR_OPERATION_TIME A where A.ID = @WorkTimeID;

if datediff(day,@dBeg,@dEnd) > 5
  return datediff(day,@dBeg,@dEnd) * 8 * 60

select @wtID = ISNULL(A.PERSONALWT,B.ID), @Calendar = ISNULL(B2.CALENDAR,B.CALENDAR)
   from COM_EMPLOYEE A with (nolock) 
   left join COM_WORKTIME B with (nolock) on B.DEPID = A.DEPID and isnull(B.WTDEFAULT,0) = 1
   left join COM_WORKTIME B2 with (nolock) on B2.ID = A.PERSONALWT
   where A.ID = @emplID;


      with
      times0 as
        (select A.DBEG as dbeg, ISNULL(A.DEND,@Now) as dend,A.ID,coalesce(B.PREP_RESULT,B.Q_IN,1) as QTY
         from PR_OPERATION_TIME A with (nolock)
         left join PR_OPERATION B with (nolock) on B.ID = A.OPERID
        where A.EMPID = @emplID
          and A.DBEG < @dEnd
          and ISNULL(A.DEND,@Now) > @dBeg),
      times as
        (select dbeg,dend,ID,case when QTY < 1 then 1 else QTY end as QTY from times0),
      points as
        (select distinct dbeg as point 
           from times
          union
         select distinct dend 
           from times
         ),
      periods as
        (select p.point as spoint, p2.point as epoint
           from points p
          cross apply (select top 1 point from points p1 where p1.point > p.point order by point) as p2
         ),
      taskperiods as (
         select ID
               , dbo.COM_WORK_MINUTS(spoint,epoint,@wtID,@Calendar,@emplID)*QTY/sum(QTY) over (partition by spoint, epoint) as busytime
           from periods
          inner join times t
               on periods.spoint >= t.dbeg
              and periods.epoint <= t.dend)
      select @res = SUM(busytime) 
        from taskperiods
        where ID = @WorkTimeID
        
      return isnull(@res,0)

END