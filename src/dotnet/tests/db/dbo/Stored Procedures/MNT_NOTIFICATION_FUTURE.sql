CREATE PROCEDURE [dbo].[MNT_NOTIFICATION_FUTURE] @UserID int
AS
BEGIN
  set nocount on

  declare @now datetime
  declare @nowDate date
  set @now = GETDATE()
  set @nowDate = CAST (@now as date)
  
  /*create table MNT_NOTIFICATION_LASTDATE (DD date not null)*/
  declare @lastDate date 
  select top 1 @lastDate = DD from MNT_NOTIFICATION_LASTDATE with (nolock)

  if @lastDate >= @nowDate or datepart(hour,@now) < 9 or datepart(hour,@now) > 12 
  begin
    set nocount off
    return
  end
  
  declare @msgs table (EMPLID int not null, MNTPLANID int, EQID int, NEXTDATE datetime, MSGROW nvarchar(max))
  insert into @msgs (EMPLID, MNTPLANID, EQID, NEXTDATE)
  select A.EMPLID, A.VNESHID, C.EQID, case when B.CRMODE in (1,2) then B.NEXTDATE when B.CRMODE in (3,4) then C.NEXTDATE end
  from MNT_PLAN_NOTYRCV A with (nolock)
  left join MNT_PLAN B with (nolock) on B.ID = A.VNESHID
  left join MNT_PLAN_EQ C with (nolock) on C.VNESHID = B.ID and B.CRMODE in (3,4)
  left join EQ_EQUIPMENT Q with (nolock) on Q.ID = C.EQID
  where B.S_S = 1
    and B.SPERIOD > 0
    and B.NOTIFICATIONP > 0
    and A.EMPLID is not null
    and (Q.ID is null or dbo.MNT_EQ_STATE_CHECK(Q.S_S,B.EQINNOTIFICATION) = 1 /*Q.S_S IN (1000173, 1000174)*/ /*in use or reserve*/)
    and (   
            (( (B.CRMODE in (1,2) and B.NEXTDATE <= dateadd(day,B.NOTIFICATIONP,@now))
            or (B.CRMODE in (3,4) and C.NEXTDATE <= dateadd(day,B.NOTIFICATIONP,@now)))
            and B.NOTIFICATIONP_EVRDAY = 1)
            or
            (( (B.CRMODE in (1,2) and B.NEXTDATE <= dateadd(day,B.NOTIFICATIONP,@now) AND CAST(B.NEXTDATE as DATE)=dateadd(day,B.NOTIFICATIONP,@nowDate))
            or (B.CRMODE in (3,4) and C.NEXTDATE <= dateadd(day,B.NOTIFICATIONP,@now) AND CAST(C.NEXTDATE as DATE)=dateadd(day,B.NOTIFICATIONP,@nowDate)))
            and B.NOTIFICATIONP_EVRDAY = 0)
         )
    and ISNULL(B.WEEKLY_ONLY,0)=0
    
    set datefirst 1

    if datepart(weekday,getdate())=7 --воскресная рассылка
    begin
        declare @dBegin datetime, @dEnd datetime

        set @dBegin = cast(dateadd(day,-6,getdate()) as date)
        set @dEnd = cast(dateadd(week,1,getdate()) as date)
        
      insert into @msgs (EMPLID, MNTPLANID, EQID, NEXTDATE)
      select A.EMPLID, A.VNESHID, C.EQID, case when B.CRMODE in (1,2) then B.NEXTDATE when B.CRMODE in (3,4) then C.NEXTDATE end
      from MNT_PLAN_NOTYRCV A with (nolock)
      left join MNT_PLAN B with (nolock) on B.ID = A.VNESHID
      left join MNT_PLAN_EQ C with (nolock) on C.VNESHID = B.ID and B.CRMODE in (3,4)
      left join EQ_EQUIPMENT Q with (nolock) on Q.ID = C.EQID
      where B.S_S = 1
        and B.SPERIOD > 0
        and B.NOTIFICATIONP > 0
        and A.EMPLID is not null
        and (Q.ID is null or dbo.MNT_EQ_STATE_CHECK(Q.S_S,B.EQINNOTIFICATION) = 1 /*Q.S_S IN (1000173, 1000174)*/ /*in use or reserve*/)
        and (
                (--если дата уведомления на следующей неделе, либо уже прошла, либо дата выполнения операции на следующей неделе
                    B.CRMODE in (1,2) and 
                        ( 
                            (@now<dateadd(day,(-1)*B.NOTIFICATIONP,B.NEXTDATE) and dateadd(day,(-1)*B.NOTIFICATIONP,B.NEXTDATE)<@dEnd) or
                            (@now>=dateadd(day,(-1)*B.NOTIFICATIONP,B.NEXTDATE) and @now<B.NEXTDATE) or
                            (@now<dateadd(day,(-1)*B.NOTIFICATIONP,B.NEXTDATE) and B.NEXTDATE<@dEnd)
                        )
                )
                or (
                    B.CRMODE in (3,4) and 
                        (
                            (@now<dateadd(day,(-1)*B.NOTIFICATIONP,C.NEXTDATE) and dateadd(day,(-1)*B.NOTIFICATIONP,C.NEXTDATE)<@dEnd) or
                            (@now>=dateadd(day,(-1)*B.NOTIFICATIONP,C.NEXTDATE) and @now<C.NEXTDATE) or
                            (@now<dateadd(day,(-1)*B.NOTIFICATIONP,C.NEXTDATE) and C.NEXTDATE<@dEnd)
                        )
                )
             )
        and ISNULL(B.WEEKLY_ONLY,0)=1

    end
  

  update @msgs set MSGROW = dbo.MNT_NOTIFICATION_HTMLROW(MNTPLANID, EQID, NEXTDATE)
  
  declare @oneEmplID int
  declare @oneMessage nvarchar(max)
  declare @oneTable nvarchar(max)
  
  declare nxx cursor local read_only for 
  select distinct EMPLID from @msgs
  open nxx 
  WHILE 1=1
  BEGIN
    FETCH NEXT FROM nxx INTO @oneEmplID
    IF @@FETCH_STATUS<>0 BREAK;
    
    set @oneTable = ''
    set @oneMessage = 'Dear All,<br><br>The following operations will soon be created based on defined maintenance plans:<br><br>'
    
    set @oneMessage = @oneMessage + '<font size="-2"><table width="1000" cellspacing = "1" bgcolor="#eeeeee" border="1" bordercolor="#ffffff">'
    set @oneMessage = @oneMessage + '<tr><th>Maintenance Plan</th><th>Next Execution Date</th><th>Equipment Type</th><th>Equipment Model</th><th>Equipment SN</th><th>Equipment TAG Nr.</th><th>Working Place</th><th>Department</th><th>Responsible Person</th><th>State</th></tr>'
    
    select @oneTable = @oneTable + A.MSGROW
      from @msgs A where A.EMPLID = @oneEmplID order by A.NEXTDATE 
    
    set @oneMessage = @oneMessage + @oneTable + '</table></font><br><br>Please, do not answer this e-mail.<br>Production Database'
    
    exec MSG_SEND_TOEMPLOYEE @UserID, @oneEmplID, 'Maintenance Plan Notification', @oneMessage
    --insert into @msg2 (EMPLID, MSG) values (@oneEmplID,@oneMessage)
    
  END
  close nxx;
  deallocate nxx;   
  
  /* запуск оповещения по просроченным */
  exec MNT_NOTIFICATION_PART2 @UserID
  
  
  
  update MNT_NOTIFICATION_LASTDATE set DD = @nowDate
  if @@rowcount = 0
    insert into MNT_NOTIFICATION_LASTDATE (DD) values (@nowDate)  

END