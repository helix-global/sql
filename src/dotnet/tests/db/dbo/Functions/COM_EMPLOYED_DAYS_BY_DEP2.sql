CREATE function [dbo].[COM_EMPLOYED_DAYS_BY_DEP2] (@depId int, @EmplID int, @dBeg datetime, @dEnd datetime, @includeChildDeps bit)
returns @res table (DD date, WTID int)
as 
begin
   /* 
   функция возвращает даты когда сотрудник был "оформлен" между датой принятия и датой увольнения и рабочий график в эти дни
   */

  declare @deps table (ID int primary key)
  
  insert into @deps (ID)
  values (@DepId)

  if (@includeChildDeps = 1)
  begin
    insert into @deps (ID)
    select ID from dbo.COM_GETCHILD_DEPARTMENTS2(@DepID,0)
  end

   declare @firstD date
   declare @lastD date
   declare @state int
   declare @emplDepId int
   
   select @firstD = isnull(isnull(A.EMPDATE,A.S_CDT),'20000101')
         ,@lastD = isnull(A.DISSDATE,'22000101')
         ,@state = A.S_S
         ,@emplDepId = A.DEPID
  from COM_EMPLOYEE A with (nolock)
  where A.ID = @EmplID

  if (exists (select B.ID from COM_EMPL_PERIODS B with (nolock) where B.EMPLID = @EmplID))
  begin
    insert into @res (DD, WTID)
    select A.DDATE, dbo.COM_WORKTABLE_BY_DATE(A.DDATE,@EmplID)/*KB1592 dbo.COM_PERSONALWT_BY_DATE(A.DDATE,@EmplID)*/
    from dbo.COM_DAY_PERIOD(@dBeg,@dEnd) A
    where exists (select B.ID from COM_EMPL_PERIODS B with (nolock) where B.EMPLID = @EmplID and B.DEPID in (select ID from @deps) and B.DBEG <= A.DDATE and (B.DEND is null or B.DEND >= A.DDATE))
  end
  else
  begin
    insert into @res (DD, WTID)
    select A.DDATE, dbo.COM_WORKTABLE_BY_DATE(A.DDATE,@EmplID) /*KB1592 dbo.COM_PERSONALWT_BY_DATE(A.DDATE,@EmplID)*/
    from dbo.COM_DAY_PERIOD(@dBeg,@dEnd) A
    where A.DDATE >= @firstD and A.DDATE <= @lastD
      and @emplDepId in (select ID from @deps)
  end
   
                      
   return
    
end