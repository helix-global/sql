CREATE FUNCTION [dbo].[COM_VACATION_MINUTES_BYDAYS](@vID int)
RETURNS 
@res TABLE 
(
	DD date
	,MINUTES decimal(18,2)
	,WORKMINUTES decimal(18,2)
	PRIMARY KEY (DD)
)
AS
BEGIN
    /* раскладывает отпуск по датам и определяет кол-во рабочих минут, вошедщих в дату отпуска  */
    
    declare @emplid int
    declare @vType int
    declare @dbeg date
    declare @dend date
    declare @periodType int
    declare @shAbsBeg datetime
    declare @shAbsDurat int
    declare @calendar int
    declare @wtID int
    declare @specialShort int  
    
    select @emplid = A.EMPLID
          ,@vType = A.VACATIONTYPE
          ,@dbeg = A.DBEG
          ,@dend = isnull(A.DEND,A.DBEG)
          ,@periodType = isnull(A.PERIODTYPE,1)
          ,@shAbsBeg = A.SHORTSTART
          ,@shAbsDurat = A.SHORTDURATION
          ,@wtID = ISNULL(E.PERSONALWT,B.ID)
          ,@calendar = ISNULL(B2.CALENDAR,B.CALENDAR)
          ,@specialShort = ISNULL(A.P_SPLEAVE_SHORT,0)
    from COM_VACATION A with (nolock)
    left join COM_EMPLOYEE E with (nolock) on E.ID = A.EMPLID
    left join COM_WORKTIME B with (nolock) on B.DEPID = E.DEPID and isnull(B.WTDEFAULT,0) = 1
    left join COM_WORKTIME B2 with (nolock) on B2.ID = E.PERSONALWT
    where A.ID = @vID
    
    if @vtype = 70 and @specialShort = 1
    begin
		set @vType = 999
    end
    
    if @vType in (30,80,200,999)  /*short absence, int appointment*/
    begin

      /* TODO по графику работы вычислять рабочие минуты ? (если к примеру короткое отсутствие с 16:00 на 4 часа) */
      /* TODO убрать выходные и праздники для коротких отсутствий ? (если короткое отсутствие заведено на воскресенье) */
      
      declare @sourcePeriod DatePeriodTableType
      declare @targetPeriod DatePeriodTableType
      
      set @shAbsBeg = cast(cast(@dbeg as date) as datetime) + cast(cast(@shAbsBeg as time) as datetime)

      insert into @sourcePeriod
      values (@shAbsBeg,dateadd(mi, @shAbsDurat, @shAbsBeg))

      insert into @targetPeriod
      select DBEG,DEND from dbo.COM_WORKPERIODS2(@shAbsBeg,@shAbsBeg,@calendar,@wtID,@emplid)

      insert into @res (DD,MINUTES,WORKMINUTES)
      values (@dbeg,@shAbsDurat,@shAbsDurat-isnull((select sum(isnull(datediff(mi,DBEG,DEND),0)) from dbo.COM_DATE_PERIOD_SUBSTRACT_TABLE(@sourcePeriod, @targetPeriod)),0))
      
      return
    
    end
    else
    begin
    
      insert into @res (DD,MINUTES)
      select DD, case when @periodType in (2,3/*forenoon,afternoon*/) then AMOUNT/2 else AMOUNT end
      from (
      select cast(DBEG as date) as DD
            ,sum(datediff(mi,DBEG,DEND)) as AMOUNT
        from dbo.COM_WORKPERIODS2(@dbeg,@dend,@calendar,@wtID,@emplid) 
        where DBEG is not null
       group by cast(DBEG as date)
       ) M
    
    end

	RETURN 
	
END