CREATE function dbo.COM_EMPLOYED_DAYS ( @EmplID int, @dBeg datetime, @dEnd datetime)
returns @res table (DD date)
as 
begin
   /* 
   функция возвращает даты когда сотрудник был "оформлен" между датой принятия и датой увольнения
   */

   declare @firstD date
   declare @lastD date
   declare @state int
   
   select @firstD = isnull(isnull(A.EMPDATE,A.S_CDT),'20000101')
         ,@lastD = isnull(A.DISSDATE,'22000101')
         ,@state = A.S_S
  from COM_EMPLOYEE A with (nolock)
  where A.ID = @EmplID

  if (exists (select B.ID from COM_EMPL_PERIODS B with (nolock) where B.EMPLID = @EmplID))
  begin
    insert into @res (DD)
    select A.DDATE
    from dbo.COM_DAY_PERIOD(@dBeg,@dEnd) A
    where exists (select B.ID from COM_EMPL_PERIODS B with (nolock) where B.EMPLID = @EmplID and B.DBEG <= A.DDATE and (B.DEND is null or B.DEND >= A.DDATE))
  end
  else
  begin
    insert into @res (DD)
    select A.DDATE
    from dbo.COM_DAY_PERIOD(@dBeg,@dEnd) A
    where A.DDATE >= @firstD and A.DDATE <= @lastD
  end
   
                      
   return
    
end