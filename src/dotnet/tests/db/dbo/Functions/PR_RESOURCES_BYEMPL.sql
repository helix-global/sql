CREATE function [dbo].[PR_RESOURCES_BYEMPL](@aEmplID int, @aDBeg datetime,@aDEnd datetime,@aMode int)
returns decimal(18,2) as
begin
  /* вычисляет доступные минуты по сотруднику */
  /* на основании графиков работы и рабочих дней за вычетом отпусков и плюс переработки */
  /*@aMode = 1 - с учетом отпусков 
             0 - без учета отпусков  
             99 - наличие сотрудника в этом периоде*/
  
  /* 10.11.17 
  добавлен режим 50 - время, списанное сотрудником под изделия
  */
  
  
  declare @res decimal(18,2)
  
  declare @dFrom datetime
  declare @dTo datetime
  declare @Calendar int
  declare @wtID int

  
  select @dFrom = isnull(isnull(A.EMPDATE,A.S_CDT),'20000101')
        ,@dTo = isnull(A.DISSDATE,'22000101')
        ,@wtID = ISNULL(A.PERSONALWT,B.ID)
        ,@Calendar = ISNULL(B2.CALENDAR,B.CALENDAR)
  from COM_EMPLOYEE A with (nolock)
  left join COM_WORKTIME B with (nolock) on B.DEPID = A.DEPID and isnull(B.WTDEFAULT,0) = 1
  left join COM_WORKTIME B2 with (nolock) on B2.ID = A.PERSONALWT
  where A.ID = @aEmplID


  declare @dbeg datetime = @aDBeg  
  declare @dend datetime = @aDEnd
  
  if @dFrom > @dend
    return 0
  if @dTo < @dbeg
    return 0  

  if @aMode = 99
    return 1 /* если дошли до этого места, то сотрудник был доступен в этот период */
  
  if @dFrom > @dbeg 
    set @dbeg = @dFrom
  if @dTo < @dend 
    set @dend = @dTo
  
  if @aMode in (1,0)
  begin
  
    select @res = dbo.COM_WORK_MINUTS4(@dbeg, @dend, @wtID, @calendar,@aEmplID,@aMode)
  
  end
  else if @aMode in (50)
  begin
  
  
   select @res =sum(case MO.TC_ACTION when 2 then coalesce(TT.ELAPSEDCORR,TT.ELAPSED_D,0) + isnull(MO.TC_MINUTE,0)
                                                                   when 1 then isnull(MO.TC_MINUTE,0)
																   else coalesce(TT.ELAPSEDCORR,TT.ELAPSED_D,0) end
                                                 )
        from PR_OPERATION_TIME TT with (nolock)
        left join PR_OPERATION A with (nolock) on A.ID = TT.OPERID
		left join PR_DEVICE DEV with (nolock) on DEV.ID = A.DEVICEID
		left JOIN PR_PRORDER O with (nolock) on O.ID = A.ORDERID
		left join PR_MAP_OPER MO with (nolock) on MO.ID = A.REVOPERID
		WHERE 
		  A.ORDERID is not null
		  and A.S_S in (1000013,1000019)
		  and A.COMPLETED_DT >= @dbeg
		  and A.COMPLETED_DT < @dend
		  and TT.EMPID = @aEmplID
  
  end

  return @res
end