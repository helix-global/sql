CREATE function [dbo].[COM_ATTENDANCE_TIME](@aUserID int,@aEmplID int,@aDay datetime)
returns int as 
begin

   declare @emplID int
   if @aEmplID is not null
     set @emplID = @aEmplID
   else
     select @emplID = A.EMPLOYEEID from DEF_USERS A with (nolock) where A.ID = @aUserID

   declare @dd datetime
   set @dd = CAST(@aDay as date)

   declare @Calendar int
   declare @wtID int

   select @wtID = ISNULL(A.PERSONALWT,B.ID), @Calendar = ISNULL(B2.CALENDAR,B.CALENDAR)
   from COM_EMPLOYEE A with (nolock) 
   left join COM_WORKTIME B with (nolock) on B.DEPID = A.DEPID and isnull(B.WTDEFAULT,0) = 1
   left join COM_WORKTIME B2 with (nolock) on B2.ID = A.PERSONALWT
   where A.ID = @emplID;
   
   declare @workIntervals table (dbeg datetime, dend datetime)

   declare @wturn int
   select @wturn = A.WTURN from COM_TURNS A with (nolock) where A.EMPLID = @emplID and A.DD = @dd
   set @wturn = ISNULL(@wturn,1)

   if dbo.COM_IS_WORKDAY2(@dd,@Calendar,@wtID) = 1
   begin
      insert into @workIntervals (dbeg,dend)  
      select @dd + cast(cast(A.TFROM as time) as datetime)
            ,case when cast(A.TTO as time)< cast(A.TFROM as time) then dateadd(day,1,@dd) else @dd end + cast(cast(A.TTO as time) as datetime) 
        from COM_WORKTIME_BR A with (nolock) 
       where A.VNESHID = @wtID 
         and A.WTURN = @wturn 
   end

   insert into @workIntervals (dbeg,dend)  
   select A.DBEG, A.DEND from COM_ADDED_WORKTIME A with (nolock) 
   where A.EMPLID = @emplID 
     and (cast(A.DBEG as DATE) = @dd or cast(A.DEND as DATE) = @dd)
  
   if (select COUNT(*) from @workIntervals) = 0
     return null 
  
   update @workIntervals set dbeg = @dd where dbeg < @dd
   update @workIntervals set dend = @dd + 1 where dend > (@dd + 1);
 
   declare @res int;
 
      with
      times as
        (select dbeg,  dend
         from @workIntervals ),
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
         select datediff(mi, spoint, epoint)/COUNT(*) over (partition by spoint, epoint) as worktime
           from periods
          inner join times t
               on periods.spoint >= t.dbeg
              and periods.epoint <= t.dend)
      select @res = SUM(worktime) 
        from taskperiods

      return isnull(@res,0)

end