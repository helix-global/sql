-- 2025-01-20   Azure#6215  [PM] Time Tracking Report: fix employee's period of work in the department.
-- 2025-01-20   Azure#6173  [PM] Add to mailing list's Time Tracking Report other employees: send similar emails (Monday - for last week, Tuesday-Friday - for current week) for heads and usual employees.
--              KB5391      Refactoring. Time-track calculation using [PM_TIMETRACK_SUMDAY] function.
--              KB2172      во вторник,среду,четверг,пятницу присылать сотруднику и сводное письмо начальнику за предыдущие дни недели; в понедельник присылать только сводное письмо начальнику за предыдущую неделю
--
-- run in test mode: EXEC [dbo].[PM_TIMETRACK_NOTIFICATION] @UserID = 1620 /*IPGL-PDB-Agent*/, @Mode = 8, @TestDate = '20260122', @TestDepID = 167 /*ME*/
--
CREATE PROCEDURE [dbo].[PM_TIMETRACK_NOTIFICATION]
  @UserID int,
  @Mode int,
  @TestDate datetime = null,
  @TestDepID int = null
as
begin
  set nocount on

  declare
    @Now datetime = isnull(@TestDate, getdate()),
    @NowD date = cast(isnull(@TestDate, getdate()) as date);

  -- Verify if we need to run now.
  if @TestDepID is null
    and (datepart(hour, @Now) < 7 or datepart(hour, @Now) > 12)
  begin
    set nocount off;
    return;
  end

  if not exists (select [a].[ID]
                 from [dbo].[PM_TT_NOTIFY_T] [a] with(nolock)
                   left join [dbo].[PM_TT_NOTIFY] [b] with(nolock) on [b].[ID]=[a].[VNESHID]
                 where isnull([b].[ENABL],0) = 1
                )
  begin
    set nocount off
    return
  end

  declare @DayOfWeek int = [dbo].[COM_DAY_OF_WEEK](@Now)

  if @DayOfWeek not in (1, 2, 3, 4, 5) and @TestDepID is null
  begin
    set nocount off;
    return;
  end

  -- Get first department which was not notified yet
  declare @NotifyID int, @DepID int;

  select top 1
    @NotifyID = [ID],
    @DepID = [DEPID]
  from [dbo].[PM_TT_NOTIFY] (nolock)
  where
    isnull([ENABL], 0) = 1
    and
    ((isnull([LAST_EXECDD], dateadd(day, -1, @NowD)) < @NowD and @TestDepID is null)
        or (@TestDepID is not null and [DEPID] = @TestDepID));

  if @NotifyID is null
  begin
    set nocount off;
    return;
  end

  declare @Dates table ([DD] date primary key clustered);

  if @DayOfWeek = 1
  begin
    /* понедельник-пятница прошлой недели */
    declare @MondayPrevWeek date = dateadd(week, -1, [dbo].[COM_WEEKDAY](@NowD, 1))

    insert into @Dates ([DD])
    select [DDATE]
    from [dbo].[COM_DAY_PERIOD](@MondayPrevWeek, dateadd(day, 5, @MondayPrevWeek))
    where [dbo].[COM_DAY_OF_WEEK]([DDATE]) in (1,2,3,4,5)
  end
  else begin
    /* поденельник-вчера, не включая сегодня */
    declare @TempDD date = @NowD
    declare @i int = @DayOfWeek

    while (@i > 1)
    begin
      select @TempDD = dateadd(day, -1, @TempDD), @i = @i - 1

      insert into @Dates ([DD])
      values (@TempDD)
    end
  end

  declare @Attendance table
  (
    [DD] date,
    [EMPLID] int,
    [NAME] nvarchar(200),
    [AVAIL] decimal(12,1),
    [TRACKED] decimal(12,1),
    [DELTA] decimal(12,1),
    primary key clustered ([DD], [EMPLID])
  )

  insert into @Attendance ([DD], [EMPLID], [NAME], [AVAIL], [TRACKED])
  select
      dates.[DD],
      pmTTNotify.[EMPLID],
      isnull(employee.[NAME], 'N/A') as [NAME],
      [dbo].[COM_ATTENDANCE_TIME2](null, pmTTNotify.[EMPLID], dates.[DD]) as [AVAIL],
      [dbo].[PM_TIMETRACK_SUMDAY](pmTTNotify.[EMPLID], dates.[DD], 0) * 60 as [TRACKED]
      --,dates.*, employeeDeps.*, depIDs.* -- TEST
  from
    [dbo].[PM_TT_NOTIFY_T] pmTTNotify (nolock)
    join [dbo].[COM_EMPLOYEE] employee (nolock) on employee.[ID] = pmTTNotify.[EMPLID]
    cross join @Dates dates
    cross apply [dbo].[COM_EMPLOYEE_DEPS](employee.[ID]) employeeDeps
    join [dbo].[COM_GETCHILD_DEPARTMENTS2](@DepID, 1) depIDs on depIDs.[ID] = employeeDeps.[DEPID]
  where
    pmTTNotify.[VNESHID] = @NotifyID
    and employee.[S_S] <> 1000092 /*dismissed*/ /*KB3179*/
    and dates.[DD] between employeeDeps.[DBEG] and isnull(employeeDeps.[DEND], @NowD)

  if @Mode = 8
  begin
    update @Attendance
    set [AVAIL] = 8 * 60
    where [AVAIL] is null
  end
  else
  begin
    update @Attendance
    set [AVAIL] = 0
    where [AVAIL] is null
  end

  update @Attendance
  set
    [TRACKED] = isnull([TRACKED], 0),
    [DELTA] = isnull([AVAIL], 0) - isnull([TRACKED], 0);

  -- Verify data
  -- select * from @Attendance order by EMPLID, DD

  
  declare @HtmlBody nvarchar(max), @CurrEmplID int, @NeedToSend bit;

  -- Send separate emails to each employee having high Delta
  declare EmplCursor cursor local read_only for select distinct [EMPLID] from @Attendance where [DELTA] > 1;

  open EmplCursor

  while 1=1
  begin
    fetch next from EmplCursor into @CurrEmplID;
    if @@FETCH_STATUS <> 0 break;

    select @HtmlBody = '',  @NeedToSend = 0;

    select @HtmlBody = concat('<p class="segoe">Dear ', isnull([GIVENNAME], [NAME]),
      ',<br><br>Please find below the information about your Time Tracking and Available Working Time:</p><br>
      <table style="padding: 0px; margin: 0px; border-collapse: collapse; border-spacing: 0px;" border="1" bordercolor="gray">
        <tr class="header">
          <th>Date</th>
          <th>Employee</th>
          <th>Available Working Time (min)</th>
          <th>Time Tracking (min)</th>
          <th>Delta (min)</th>
        </tr>')
    from [dbo].[COM_EMPLOYEE] (nolock)
    where [ID] = @CurrEmplID;

    select
      @NeedToSend = 1,
      @HtmlBody = concat(@HtmlBody,
        '<tr class="value">',
        '<td style="text-align: left;">', convert(nvarchar, attendance.[DD], 104),
        '</td><td style="text-align: left;">', attendance.[NAME],
        '</td><td style="text-align: center;">', isnull(convert(nvarchar(20), attendance.[AVAIL]), 'N/A'),
        '</td><td style="text-align: center;">', convert(nvarchar(20), attendance.[TRACKED]),
        '</td><td style="text-align: center;" bgcolor="#ffb7ae">', convert(nvarchar(20), attendance.[DELTA]),
        '</td></tr>')
    from
      @Attendance attendance
    where attendance.[EMPLID] = @CurrEmplID and attendance.[DELTA] > 1 /*KB2840 разница больше минуты, а не больше нуля*/
    order by attendance.[DD]

    set @HtmlBody = concat('<html xmlns="http://www.w3.org/1999/xhtml">
      <head>
        <style type="text/css">
          .header
            {
              margin: 0px;
              padding: 2px 15px 1px 15px;
              border-style: solid;
              border-width: 1px;
              border-color: white #134a8f white #134a8f;
              color: white;
              background-color: #134a8f;
              font-family: ''Segoe UI'', Tahoma, Geneva, Verdana, sans-serif;
              font-size: 14px;
            }
          .value
            {
              margin: 0px;
              border: 1px solid #134a8f;
              font-family: ''Segoe UI'', Tahoma, Geneva, Verdana, sans-serif;
              font-size: 14px;
            }
          .segoe-small
            {
              font-family: ''Segoe UI'', Tahoma, Geneva, Verdana, sans-serif; font-size: 12px; text-indent:0pt; margin:0pt 0pt 0pt 0pt
            }
          .segoe
            {
              font-family: ''Segoe UI'', Tahoma, Geneva, Verdana, sans-serif; font-size: 14px; text-indent:0pt; margin:0pt 0pt 0pt 0pt
            }
          th, td
            {
              padding: 1px 15px 1px 15px;
            }
        </style>
      </head>
      <body>', @htmlBody, '</table>
      <br><p class="segoe-small">This e-mail was created automatically. Please do not respond.<br/>PDB</p>
      </body></html>');
        
    if @NeedToSend = 1
    begin
      exec [dbo].[MSG_SEND_TOEMPLOYEE] @UserID, @CurrEmplID, 'Time Tracking Report', @HtmlBody
    end
  end

  close EmplCursor;
  deallocate EmplCursor;


  -- Send email to department head
  select
    @NeedToSend = 0,
    @HtmlBody = '<p class="segoe">Dear All,<br><br>Please find below the information about employees'' Time Tracking and Available Working Time:</p><br>
      <table style="padding: 0px; margin: 0px; border-collapse: collapse; border-spacing: 0px;" border="1" bordercolor="gray">
        <tr class="header">
          <th>Date</th>
          <th>Employee</th>
          <th>Available Working Time (min)</th>
          <th>Time Tracking (min)</th>
          <th>Delta (min)</th>
        </tr>';

  select @NeedToSend = 1,
    @HtmlBody = concat(@HtmlBody,
      '<tr class="value">',
      '<td style="text-align: left;">', convert(nvarchar(20), attendance.[DD], 104),
      '</td><td style="text-align: left;">', attendance.[NAME],
      '</td><td style="text-align: center;">', isnull(convert(nvarchar(20), attendance.[AVAIL]), 'N/A'),
      '</td><td style="text-align: center;">', convert(nvarchar(20), attendance.[TRACKED]),
      '</td><td style="text-align: center;" bgcolor="#ffb7ae">', convert(nvarchar(20), attendance.[DELTA]),
      '</td></tr>')
  from @Attendance attendance
  where attendance.[DELTA] > 1 /*KB2840 разница больше минуты, а не больше нуля*/
  order by attendance.[DD], attendance.[NAME]

  set @HtmlBody = concat('<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
      <style type="text/css">
        .header
          {
            margin: 0px;
            padding: 2px 15px 1px 15px;
            border-style: solid;
            border-width: 1px;
            border-color: white #134a8f white #134a8f;
            color: white;
            background-color: #134a8f;
            font-family: ''Segoe UI'', Tahoma, Geneva, Verdana, sans-serif;
            font-size: 14px;
          }
        .value
          {
            margin: 0px;
            border: 1px solid #134a8f;
            font-family: ''Segoe UI'', Tahoma, Geneva, Verdana, sans-serif;
            font-size: 14px;
          }
        .segoe-small
          {
            font-family: ''Segoe UI'', Tahoma, Geneva, Verdana, sans-serif; font-size: 12px; text-indent:0pt; margin:0pt 0pt 0pt 0pt
          }
        .segoe
          {
            font-family: ''Segoe UI'', Tahoma, Geneva, Verdana, sans-serif; font-size: 14px; text-indent:0pt; margin:0pt 0pt 0pt 0pt
          }
        th, td
          {
            padding: 1px 15px 1px 15px;
          }
      </style>
    </head>
    <body>', @htmlBody, '</table>
    <br><p class="segoe-small">This e-mail was created automatically. Please do not respond.<br/>PDB</p>
    </body></html>');

  if @NeedToSend = 1 /*KB3024*/
  begin
    exec [dbo].[MSG_SEND_TODEP_HEADS] @UserID, @DepID, null, 0, 'Time Tracking Report', @HtmlBody
  end

  update [dbo].[PM_TT_NOTIFY]
  set [LAST_EXECDD] = @NowD
  where [ID] = @NotifyID

  set nocount off;
end