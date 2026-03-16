CREATE procedure [dbo].[PRR_2WORKSHIFT_CALC](@RequestID int, @UserID int)
as 
BEGIN

  delete from PRR_2WORKSHIFT_DATA where VNESHID = @RequestID
  
  declare @depId int
  declare @yy int
  declare @mm int
  
  select @depId = A.DEPID
        ,@yy = A.YY
        ,@mm = A.MM
  from PRR_2WORKSHIFT A with(nolock)
  where A.ID = @RequestID
  
  declare @startDate datetime
  declare @endDate datetime
  
  set @startDate = dbo.COM_ENCODE_DATE(@yy,@mm,1)
  set @endDate = dateadd(second, -1, dateadd(month, 1, @startDate))
  
declare @result table (EMPLID int primary key, DAYS nvarchar(max), PERSONALNO nvarchar(20), NAME nvarchar(200), MM int, YY int, WTID int, DAYCOUNT int, ALLHOURS float, NIGHTHOURS float, DAYHOURS float)
declare @employees table (EMPLID int, DD int, MM int, YY int, DATE date, WTID int, ALLHOURS float, NIGHTHOURS float, DAYHOURS float, WTURN int)

insert into @employees (EMPLID, DD, MM, YY, DATE, WTID, WTURN)
select E.ID, day(T.DD), month(T.DD), year(T.DD), T.DD, dbo.COM_WORKTABLE_BY_DATE2(T.DD,E.ID) /*KB2797 dbo.COM_WORKTABLE_BY_EMPL(E.ID)*/, T.WTURN
from COM_TURNS T
left join COM_EMPLOYEE E on T.EMPLID = E.ID
where T.DD>=@startDate 
  and T.DD<=@endDate
  /*and T.WTURN>=2*//*KB3494*/
  and E.DEPID in (select A.ID from dbo.COM_GETCHILD_DEPARTMENTS2(@depId,1) A)
  and isnull(E.ISTEMP,0) <> 1

update @employees
set ALLHOURS = (
    select sum(datediff(minute, WP.DBEG, WP.DEND)) / 60.0
    from dbo.COM_REAL_WORKPERIODS2(dateadd(hh, 14, datediff(dd, 0, DATE)),dateadd(hh, 26, datediff(dd, 0, DATE)),null,WTID,EMPLID) WP
  )

update @employees
set NIGHTHOURS = (
    select sum(datediff(minute, WP.DBEG, WP.DEND)) / 60.0
    from dbo.COM_REAL_WORKPERIODS2(dateadd(hh, 20, datediff(dd, 0, DATE)),dateadd(hh, 26, datediff(dd, 0, DATE)),null,WTID,EMPLID) WP
  )

update @employees
set DAYHOURS = (
    select sum(datediff(minute, WP.DBEG, WP.DEND)) / 60.0
    from dbo.COM_REAL_WORKPERIODS2(dateadd(hh, 14, datediff(dd, 0, DATE)),dateadd(hh, 20, datediff(dd, 0, DATE)),null,WTID,EMPLID) WP
  )
  where WTURN > 1 /*KB3531*/

insert into @result (EMPLID, YY, MM, PERSONALNO, NAME, WTID, ALLHOURS, NIGHTHOURS, DAYHOURS, DAYS, DAYCOUNT)
select t1.EMPLID, t1.YY, t1.MM
      ,min(E.PERSONALNO) 
      ,min(E.NAME) 
      ,min(t1.WTID) 
      ,sum(t1.ALLHOURS) 
      ,sum(t1.NIGHTHOURS) 
      ,sum(t1.DAYHOURS) 
      ,','+dbo.GROUP_CONCAT_D(t1.DD,',')+','  /*TODO это и нижеследующие строчки с like '%,1,%' сохранилось чтобы взять алгоритм из старого отчета с минимумом переделок, но наверное можно сделать иначе*/
	  ,count(t1.DD)
from @employees t1
left join COM_EMPLOYEE E on t1.EMPLID = E.ID
where /*t1.ALLHOURS is not null and t1.NIGHTHOURS is not null and t1.DAYHOURS is not null*/ /*KB2530*/
       isnull(t1.ALLHOURS,0) <> 0 /*KB3309*/
group by t1.EMPLID, t1.YY, t1.MM


INSERT INTO PRR_2WORKSHIFT_DATA
(GID,S_CR,S_CDT,VNESHID,EMPLID
 ,TOTAL1,TOTALNIGHT,TOTALDAY
 ,TFROM1,TTO1,TFROM2,TTO2
 ,WTID,GROUPCOLUMN
 )
select newid(), @UserID, getdate(), @RequestID, M.EMPLID
 ,DAYCOUNT,NIGHTHOURS,DAYHOURS
 ,TFROM1,TTO1,TFROM2,TTO2
 ,WTID,GROUPCOLUMN
from(
select R.*
, WT1.TFROM as TFROM1, WT1.TTO as TTO1, WT2.TFROM as TFROM2, WT2.TTO as TTO2
, convert(nvarchar,R.MM)+convert(nvarchar,cast(WT2.TFROM as time))+convert(nvarchar,cast(WT2.TTO as time)) as GROUPCOLUMN 
from @result R
cross apply 
  (
   select min(TFROM) as TFROM, max(TTO) as TTO
   from (select WTURN,VNESHID,TFROM, (case when TTO>TFROM then TTO else dateadd(day, 1, TTO) end) as TTO from COM_WORKTIME_BR) WT
   where WT.WTURN = 1
     and WT.VNESHID = R.WTID
  ) WT1
cross apply 
  (
   select min(TFROM) as TFROM, max(TTO) as TTO
   from (select WTURN,VNESHID,TFROM, (case when TTO>TFROM then TTO else dateadd(day, 1, TTO) end) as TTO from COM_WORKTIME_BR) WT
   where WT.WTURN = 2
     and WT.VNESHID = R.WTID
  ) WT2
) M  
order by GROUPCOLUMN, case when ISNUMERIC(M.PERSONALNO + '.e0') = 1 then cast(M.PERSONALNO as int) else 0 end 


update PRR_2WORKSHIFT_DATA set D1 = dbo.PRR_2WORKSHIFT_LETTER(EMPLID,@yy,@mm,1) where VNESHID = @RequestID
update PRR_2WORKSHIFT_DATA set D2 = dbo.PRR_2WORKSHIFT_LETTER(EMPLID,@yy,@mm,2) where VNESHID = @RequestID
update PRR_2WORKSHIFT_DATA set D3 = dbo.PRR_2WORKSHIFT_LETTER(EMPLID,@yy,@mm,3) where VNESHID = @RequestID
update PRR_2WORKSHIFT_DATA set D4 = dbo.PRR_2WORKSHIFT_LETTER(EMPLID,@yy,@mm,4) where VNESHID = @RequestID
update PRR_2WORKSHIFT_DATA set D5 = dbo.PRR_2WORKSHIFT_LETTER(EMPLID,@yy,@mm,5) where VNESHID = @RequestID
update PRR_2WORKSHIFT_DATA set D6 = dbo.PRR_2WORKSHIFT_LETTER(EMPLID,@yy,@mm,6) where VNESHID = @RequestID
update PRR_2WORKSHIFT_DATA set D7 = dbo.PRR_2WORKSHIFT_LETTER(EMPLID,@yy,@mm,7) where VNESHID = @RequestID
update PRR_2WORKSHIFT_DATA set D8 = dbo.PRR_2WORKSHIFT_LETTER(EMPLID,@yy,@mm,8) where VNESHID = @RequestID
update PRR_2WORKSHIFT_DATA set D9 = dbo.PRR_2WORKSHIFT_LETTER(EMPLID,@yy,@mm,9) where VNESHID = @RequestID
update PRR_2WORKSHIFT_DATA set D10 = dbo.PRR_2WORKSHIFT_LETTER(EMPLID,@yy,@mm,10) where VNESHID = @RequestID
update PRR_2WORKSHIFT_DATA set D11 = dbo.PRR_2WORKSHIFT_LETTER(EMPLID,@yy,@mm,11) where VNESHID = @RequestID
update PRR_2WORKSHIFT_DATA set D12 = dbo.PRR_2WORKSHIFT_LETTER(EMPLID,@yy,@mm,12) where VNESHID = @RequestID
update PRR_2WORKSHIFT_DATA set D13 = dbo.PRR_2WORKSHIFT_LETTER(EMPLID,@yy,@mm,13) where VNESHID = @RequestID
update PRR_2WORKSHIFT_DATA set D14 = dbo.PRR_2WORKSHIFT_LETTER(EMPLID,@yy,@mm,14) where VNESHID = @RequestID
update PRR_2WORKSHIFT_DATA set D15 = dbo.PRR_2WORKSHIFT_LETTER(EMPLID,@yy,@mm,15) where VNESHID = @RequestID
update PRR_2WORKSHIFT_DATA set D16 = dbo.PRR_2WORKSHIFT_LETTER(EMPLID,@yy,@mm,16) where VNESHID = @RequestID
update PRR_2WORKSHIFT_DATA set D17 = dbo.PRR_2WORKSHIFT_LETTER(EMPLID,@yy,@mm,17) where VNESHID = @RequestID
update PRR_2WORKSHIFT_DATA set D18 = dbo.PRR_2WORKSHIFT_LETTER(EMPLID,@yy,@mm,18) where VNESHID = @RequestID
update PRR_2WORKSHIFT_DATA set D19 = dbo.PRR_2WORKSHIFT_LETTER(EMPLID,@yy,@mm,19) where VNESHID = @RequestID
update PRR_2WORKSHIFT_DATA set D20 = dbo.PRR_2WORKSHIFT_LETTER(EMPLID,@yy,@mm,20) where VNESHID = @RequestID
update PRR_2WORKSHIFT_DATA set D21 = dbo.PRR_2WORKSHIFT_LETTER(EMPLID,@yy,@mm,21) where VNESHID = @RequestID
update PRR_2WORKSHIFT_DATA set D22 = dbo.PRR_2WORKSHIFT_LETTER(EMPLID,@yy,@mm,22) where VNESHID = @RequestID
update PRR_2WORKSHIFT_DATA set D23 = dbo.PRR_2WORKSHIFT_LETTER(EMPLID,@yy,@mm,23) where VNESHID = @RequestID
update PRR_2WORKSHIFT_DATA set D24 = dbo.PRR_2WORKSHIFT_LETTER(EMPLID,@yy,@mm,24) where VNESHID = @RequestID
update PRR_2WORKSHIFT_DATA set D25 = dbo.PRR_2WORKSHIFT_LETTER(EMPLID,@yy,@mm,25) where VNESHID = @RequestID
update PRR_2WORKSHIFT_DATA set D26 = dbo.PRR_2WORKSHIFT_LETTER(EMPLID,@yy,@mm,26) where VNESHID = @RequestID
update PRR_2WORKSHIFT_DATA set D27 = dbo.PRR_2WORKSHIFT_LETTER(EMPLID,@yy,@mm,27) where VNESHID = @RequestID
update PRR_2WORKSHIFT_DATA set D28 = dbo.PRR_2WORKSHIFT_LETTER(EMPLID,@yy,@mm,28) where VNESHID = @RequestID
update PRR_2WORKSHIFT_DATA set D29 = dbo.PRR_2WORKSHIFT_LETTER(EMPLID,@yy,@mm,29) where VNESHID = @RequestID
update PRR_2WORKSHIFT_DATA set D30 = dbo.PRR_2WORKSHIFT_LETTER(EMPLID,@yy,@mm,30) where VNESHID = @RequestID
update PRR_2WORKSHIFT_DATA set D31 = dbo.PRR_2WORKSHIFT_LETTER(EMPLID,@yy,@mm,31) where VNESHID = @RequestID
    
END