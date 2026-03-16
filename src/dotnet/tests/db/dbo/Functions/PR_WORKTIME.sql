CREATE FUNCTION [dbo].[PR_WORKTIME]
(
	@WorkTimeID int, @OperationID int, @EmplID int, @Now datetime
)
RETURNS int
AS
BEGIN
  
  if @WorkTimeID is not null
  begin
    declare @dbeg datetime
    declare @dend datetime
    declare @opEmpl int 
    select @dbeg = A.DBEG, @dend = ISNULL(A.DEND,@Now), @opEmpl = A.EMPID
      from PR_OPERATION_TIME A with (nolock)
     where A.ID = @WorkTimeID
    /*были ли другие операции в это время*/
    declare @tmp int
    select @tmp = COUNT(*) from PR_OPERATION_TIME B with (nolock)
    where B.EMPID = @opEmpl
      and B.DBEG < @dend
      and ISNULL(B.DEND,@Now) > @dbeg
      and B.ID <> @WorkTimeID
    if @tmp = 0
      return datediff(mi,@dbeg,@dend)
    else
    begin
      /*были*/
      declare @res int;
      with
      times as
        (select A.DBEG as dbeg, ISNULL(A.DEND,@Now) as dend,A.ID
         from PR_OPERATION_TIME A with (nolock)
        where A.EMPID = @opEmpl
          and A.DBEG < @dend
          and ISNULL(A.DEND,@Now) > @dbeg),
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
         select ID, datediff(mi, spoint, epoint)/COUNT(*) over (partition by spoint, epoint) as busytime
           from periods
          inner join times t
               on periods.spoint >= t.dbeg
              and periods.epoint <= t.dend)
      select @res = SUM(busytime) 
        from taskperiods
        where ID = @WorkTimeID
      return isnull(@res,0)
    end
  end
  
  return 0;

END