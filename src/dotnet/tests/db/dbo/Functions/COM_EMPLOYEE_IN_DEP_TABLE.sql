CREATE function [dbo].[COM_EMPLOYEE_IN_DEP_TABLE](@DepID int, @DateStart datetime, @DateEnd datetime, @inclSubDep int)
returns @res table (EMPLID int)
begin
  
  declare @deps table (ID int primary key)
  
  insert into @deps (ID)
  values (@DepId)

  if (@inclSubDep = 1)
  begin
    insert into @deps (ID)
    select ID from dbo.COM_GETCHILD_DEPARTMENTS2(@DepID,0)
  end
  
  insert into @res (EMPLID)
  select distinct A.EMPLID
  from COM_EMPL_PERIODS A with (nolock)
  where A.DEPID in (select ID from @deps)
    and A.DBEG <= @DateEnd 
    and isnull(A.DEND,'40000101') > @DateStart

  insert into @res (EMPLID)
  select A.ID
  from COM_EMPLOYEE A with (nolock)
  where A.DEPID in (select ID from @deps)
    and A.S_S = 1
    and not exists (select B.ID from COM_EMPL_PERIODS B with (nolock) where B.EMPLID = A.ID)
  
  return

end