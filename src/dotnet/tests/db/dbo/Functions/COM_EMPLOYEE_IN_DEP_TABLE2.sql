CREATE function [dbo].[COM_EMPLOYEE_IN_DEP_TABLE2](@DepID int, @DateStart datetime, @DateEnd datetime, @inclSubDep int)
returns @res table (EMPLID int, DEPID int)
begin
  /*по сравнению с COM_EMPLOYEE_IN_DEP_TABLE возвращает еще и DEPID*/
  declare @deps table (ID int primary key)
  
  insert into @deps (ID)
  values (@DepId)

  if (@inclSubDep = 1)
  begin
    insert into @deps (ID)
    select ID from dbo.COM_GETCHILD_DEPARTMENTS2(@DepID,0)
  end
  
  insert into @res (EMPLID, DEPID)
  select distinct A.EMPLID, A.DEPID
  from
	COM_EMPL_PERIODS A with (nolock)
	join @deps D on A.DEPID = D.ID
	left join COM_EMPL_PERIODS B with (nolock) on A.EMPLID = B.EMPLID and A.ID != B.ID and A.DEND = B.DBEG -- Сотрудники которые начали работать в другом отделе в тот же день
  where
	A.DBEG <= @DateEnd 
    and isnull(A.DEND,'40000101') >= @DateStart
	and B.ID is null

  insert into @res (EMPLID,DEPID)
  select A.ID,A.DEPID
  from COM_EMPLOYEE A with (nolock)
  where A.DEPID in (select ID from @deps)
    and A.S_S = 1
    and not exists (select B.ID from COM_EMPL_PERIODS B with (nolock) where B.EMPLID = A.ID)
  
  return

end