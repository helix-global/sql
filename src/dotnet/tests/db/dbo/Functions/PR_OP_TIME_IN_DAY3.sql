CREATE function [dbo].[PR_OP_TIME_IN_DAY3](@OpTimeID int, @aDate datetime, @now datetime)
returns decimal(12,2)
as
begin
   /*возвращает часть из учтенного времени, относящегося ко дню @aDate*/
   /*отличается от PR_OP_TIME_IN_DAY точностью decimal*/
   
   declare @dbeg datetime
   declare @dend datetime
   declare @dendclear datetime   
   declare @userid1 int
   declare @elapsed1 decimal(12,2)
   declare @emplID int
   
   select @dbeg = A.DBEG
         ,@dend = ISNULL(A.DEND,@now)
         ,@dendclear = A.DEND
         ,@userid1 = A.USERID
         ,@elapsed1 = isnull(A.ELAPSED_D,A.ELAPSED)
         ,@emplID = A.EMPID
   from PR_OPERATION_TIME A with (nolock)
   where A.ID = @OpTimeID
   
   declare @dd datetime
   set @dd = cast(@aDate as DATE)
   
   if @dendclear is not null and CAST(@dbeg as date) = @dd and  CAST(@dend as date) = @dd
     return @elapsed1
   
declare @dbeg2 datetime
declare @dend2 datetime   
   
set @dbeg2 = @dbeg
set @dend2 = @dend

if @dbeg2 < @dd
 set @dbeg2 = @dd

if @dend2 > @dd + 1
 set @dend2 = @dd + 1 
   
declare @wtID int
declare @Calendar int 
declare @res decimal(14,2)


select @wtID = ISNULL(A.PERSONALWT,B.ID), @Calendar = ISNULL(B2.CALENDAR,B.CALENDAR)
   from COM_EMPLOYEE A with (nolock) 
   left join COM_WORKTIME B with (nolock) on B.DEPID = A.DEPID and isnull(B.WTDEFAULT,0) = 1
   left join COM_WORKTIME B2 with (nolock) on B2.ID = A.PERSONALWT
   where A.ID = @emplID;


      with
      times as
        (select A.DBEG as dbeg, ISNULL(A.DEND,@Now) as dend,A.ID
         from PR_OPERATION_TIME A with (nolock)
        where A.EMPID = @emplID
          and A.DBEG < @dend
          and ISNULL(A.DEND,@Now) > @dbeg
          and A.ID <> @OpTimeID
         union all
         select @dbeg2,@dend2,@OpTimeID
          ),
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
               , dbo.COM_WORK_MINUTS3(spoint,epoint,@wtID,@Calendar,@emplID)/COUNT(*) over (partition by spoint, epoint) as busytime
           from periods
          inner join times t
               on periods.spoint >= t.dbeg
              and periods.epoint <= t.dend)
      select @res = SUM(busytime) 
        from taskperiods
        where ID = @OpTimeID
        
      return isnull(@res,0)
   
   
   return null
end;