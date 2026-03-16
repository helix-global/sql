

CREATE function [dbo].[COM_EMPLOYEE_IN_DEP_RANGE](@EmployeeID int, @DepID int, @DateStart datetime, @DateEnd datetime, @includeChildDeps bit)
returns 
@res table (DEPID int, DBEG datetime, DEND datetime)
begin
  
  declare @deps table (ID int primary key)
  
  if @DepId is not null
  begin
    insert into @deps (ID)
    values (@DepId)
  end  

  if (@includeChildDeps = 1)
  begin
    insert into @deps (ID)
    select ID from dbo.COM_GETCHILD_DEPARTMENTS2(@DepID,0) where ID is not null
  end

  declare @now datetime = getdate()

  insert into @res (DEPID, DBEG, DEND)
  select DEPID, DBEG, isnull(dateadd(minute, -1, dateadd(day, 1, DEND)), @now)
  from dbo.COM_EMPLOYEE_DEPS(@EmployeeID)
  where DEPID in (select ID from @deps)
    and DBEG<=@DateEnd and (DEND is null or DEND>=@DateStart)    

  update @res 
  set DBEG = case when DBEG>@DateStart then DBEG else @DateStart end
     ,DEND = case when DEND<=@DateEnd then DEND else @DateEnd end

  delete from @res 
  where DBEG=@now and DEND=@now
     or DBEG=DEND

  return

end