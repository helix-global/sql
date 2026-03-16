-- Stored procedure to send notifications about planned equipment maintenance.
-- Old procedures - see MNT_NOTIFICATION_FUTURE2, MNT_NOTIFICATION_PART2, functions MNT_NOTIFICATION_HTMLROW, MNT_NOTIFICATION_HTMLROW_EXP etc - are not used anymore.
--
-- History of changes:
-- KB4734 2025-10-17 New stored procedure is created for new logic (see task description).
--
-- Test: EXEC [dbo].[MNT_SEND_NOTIFICATIONS_PLANNED] 1620 /*IPGL-PDB-Agent*/, 'IgnoreRestrictions'
-- Test: EXEC [dbo].[MNT_SEND_NOTIFICATIONS_PLANNED] 1620 /*IPGL-PDB-Agent*/, 'IgnoreRestrictions,AssumeTodayIsSunday' 
CREATE PROCEDURE [dbo].[MNT_SEND_NOTIFICATIONS_PLANNED]
  @UserID int,
  @options nvarchar(max) = null
as
begin
  set nocount on

  declare @ignoreRestrictions int = 0,
    @now datetime = getdate(),
    @nowDate date = cast(getdate() as date),
    @lastSend datetime = (select top 1 [VALUEDATE] from [dbo].[COM_SYSSETTINGS] (nolock) where [LABEL] = 'mnt_last_send_notifications_planned'),
    @lastSendDate date = (select top 1 cast([VALUEDATE] as date) from [dbo].[COM_SYSSETTINGS] (nolock) where [LABEL] = 'mnt_last_send_notifications_planned');

  if charindex('IgnoreRestrictions', @options) > 0
  begin
    set @ignoreRestrictions = 1;
  end
  
  /* Run once per day from 9:00 till 12:00 */
  if (@lastSendDate >= @nowDate or datepart(hour, @now) < 9 or datepart(hour, @now) > 12) and (@ignoreRestrictions = 0)
  begin
    set nocount off;
    print 'Outside of procedure working time frame (9:00 - 12:00), now is ' + convert(varchar, @now, 120) + ', last run was on ' + convert(varchar, @lastSend, 120);
    return;
  end

  set datefirst 1; -- Monday = 1
  declare @todayIsSunday int = case when datepart(weekday, getdate()) = 7 then 1 else 0 end;

  if charindex('AssumeTodayIsSunday', @options) > 0
  begin
    set @todayIsSunday = 1;
  end

/* Maintenance Plan      Next Execution Date   Equipment Type    Equipment Model     Equipment SN    Equipment TAG Nr.   Working Place      Department    Responsible Person    State
Test Module Maintenance  05.09.2025 15:32      Test Setup        PLD-212 Setup       20056823        NA                  CB28 Raum2_Tisch5  FBA-YFB_G     Grigorii Bashkirov    In Use  */

  declare @notificationRows table (MNTPLANID int, OPERNAME nvarchar(100), NEXTDATE datetime,
    EQID int, EQTYPENAME nvarchar(200), EQMODELNAME nvarchar(100), EQSN nvarchar(100), EQTAGN nvarchar(100),
    EQWORKINKPLACE nvarchar(50), EQDEPCODE nvarchar(100), EQRESPEMPLNAME nvarchar(200), EQSTATENAME nvarchar(150),
    LINKEDEQ nvarchar(max),
    TORECIPIENTS nvarchar(max), CCRECIPIENT nvarchar(max))

  insert into @notificationRows (MNTPLANID, OPERNAME, NEXTDATE, EQID, EQTYPENAME, EQMODELNAME, EQSN, EQTAGN, EQWORKINKPLACE, EQDEPCODE, EQRESPEMPLNAME, EQSTATENAME, TORECIPIENTS, CCRECIPIENT)
  select
    mntPlan.[ID],
    mntPlanOper.[NAME] as [OPERNAME],
    case
        when mntPlan.[CRMODE] in (1 /*One Operation*/, 2 /*Each Employee In Operation Group Get Operation*/) then [dbo].[MNT_NEXT_SNOOZE4](mntPlan.[ID], null, null)
        when mntPlan.[CRMODE] in (3 /*By Equipment*/, 4 /*By Equipment (Assign Operation To Responsible Employee)*/) then mntPlanEquip.[NEXTDATE]
    end as [NEXTDATE],
    mntPlanEquip.[EQID],
    equipmentTypes.[NAME] as [EQTYPENAME],
    equipmentModels.[CODE] as [EQMODELNAME],
    equipment.[SN] as [EQSN],
    equipment.[TAGN] as [EQTAGN],
    equipment.[WORKINKPLACE] as [EQWORKINKPLACE],
    equipmentDep.[CODE] as [EQDEPCODE],
    equipmentRespEmpl.[NAME] as [EQRESPEMPLNAME],
    dbo.DEF_STATE_NAME_EN(equipment.[S_S]) as [EQSTATENAME],
    ( select
        [dbo].[GROUP_CONCAT_DS](distinct empl.[EMAIL], ';', 1)
      from [dbo].[COM_EMPLOYEE] empl (nolock)
      join [dbo].[MNT_PLAN_NOTYRCV] mntNotifRecipients (nolock) on empl.[ID] = mntNotifRecipients.[EMPLID]
      where empl.[S_S] = 1 /* only active employees */ and mntNotifRecipients.[VNESHID] = mntPlan.[ID]
    ) as [TORECIPIENTS],
    case when equipmentRespEmpl.[S_S] = 1 then equipmentRespEmpl.[EMAIL] else null end as [CCRECIPIENT]
  from
    [dbo].[MNT_PLAN] mntPlan (nolock)
    join [dbo].[PR_OPERATIONS] mntPlanOper (nolock) on mntPlanOper.[ID] = mntPlan.[OPERID]
    left join [dbo].[MNT_PLAN_EQ] mntPlanEquip (nolock) on mntPlanEquip.[VNESHID] = mntPlan.[ID] and mntPlan.[CRMODE] in (3, 4)
    left join [dbo].[EQ_EQUIPMENT] equipment (nolock) on equipment.[ID] = mntPlanEquip.[EQID]
    left join [dbo].[EQ_MODELS] equipmentModels (nolock) on equipmentModels.[ID] = equipment.[EQMODELID]
    left join [dbo].[EQ_TYPES] equipmentTypes (nolock) on equipmentTypes.[ID] = equipmentModels.[EQTYPEID]
    left join [dbo].[COM_DEPARTMENTS] equipmentDep (nolock) on equipmentDep.[ID] = equipment.[DEPID]
    left join [dbo].[COM_EMPLOYEE] equipmentRespEmpl (nolock) on equipmentRespEmpl.[ID] = equipment.[RESP_EMPLID]
  where
    --mntPlan.ID = 1115 or -- Test linked equipment (this specific maintenance plan has a lot of them)
    mntPlan.[S_S] = 1
    and mntPlan.[SPERIOD] > 0
    and mntPlan.[NOTIFICATIONP_DAYS] > 0
    and (equipment.[ID] is null or dbo.MNT_EQ_STATE_CHECK(equipment.[S_S], mntPlan.[EQINNOTIFICATION]) = 1)
    and
    (
      (
        mntPlan.[NOTIFICATIONP_EVRDAY] = 1 /* каждый день */
        and
        (
          (mntPlan.[CRMODE] in (1,2) and cast([dbo].[MNT_NEXT_SNOOZE4](mntPlan.[ID], null, null) as date) between @nowDate and dateadd(day, mntPlan.[NOTIFICATIONP_DAYS], @now))
          or (mntPlan.[CRMODE] in (3,4) and cast(mntPlanEquip.[NEXTDATE] as date) between @nowDate and dateadd(day, mntPlan.[NOTIFICATIONP_DAYS], @nowDate))
        )
      )
      or
      (
        (mntPlan.[NOTIFICATIONP_EVRDAY] = 0 /* не каждый день */ or (isnull(mntPlan.[WEEKLY_ONLY], 0) = 1 and @todayIsSunday = 1))
        and
        ( 
          (mntPlan.[CRMODE] in (1,2) AND cast([dbo].[MNT_NEXT_SNOOZE4](mntPlan.[ID], null, null) as date) = dateadd(day, mntPlan.[NOTIFICATIONP_DAYS], @nowDate))
          or (mntPlan.[CRMODE] in (3,4) AND cast(mntPlanEquip.[NEXTDATE] as date) = dateadd(day, mntPlan.[NOTIFICATIONP_DAYS], @nowDate))
        )
      )
    )
    and
    (
      isnull(mntPlan.[WEEKLY_ONLY], 0) = 0
      or
      (
        @todayIsSunday = 1
        and
        (
          (mntPlan.[CRMODE] in (1,2) and abs(datediff(day, @now, [dbo].[MNT_NEXT_SNOOZE4](mntPlan.[ID], null, null))) <= 7)
          or (mntPlan.[CRMODE] in (3,4) and abs(datediff(day, @now, mntPlanEquip.[NEXTDATE])) <= 7)
        )
      )
    )

  -- Description of linked equipment: extra lines (or nothing if there are no linked EQs) under each equipment line.
  update notifRows
  set [LINKEDEQ] =
  (
    select concat('
      <tr class="value">
        <th style="text-align: right;" colspan="2">(linked to ', notifRows.[EQSN], ')</th>
        <th style="text-align: left;">', equipmentTypes.[NAME], '</th>
        <th style="text-align: left;">', equipmentModels.[CODE], '</th>
        <th style="text-align: left;"><a href="a2l://doc/?ClassLabel=eq_equipment&ID=', cast(equipment.[ID] as nvarchar(10)), '">', equipment.[SN], '</a></th>
        <th style="text-align: left;">', equipment.[TAGN], '</th>
        <th style="text-align: left;">', equipment.[WORKINKPLACE], '</th>
        <th style="text-align: left;">', equipmentDep.[CODE], '</th>
        <th style="text-align: left;">', equipmentRespEmpl.[NAME], '</th>
        <th style="text-align: left;">', dbo.DEF_STATE_NAME_EN(equipment.[S_S]), '</th>
      </tr>')
    from
      [dbo].[MNT_PLAN_EQ] mntPlanEquip (nolock)
      join [dbo].[MNT_PLAN_EQ_LINKED_EQ] mntPlanLinkedEquip (nolock) on mntPlanLinkedEquip.[VNESHID] = mntPlanEquip.[ID]
      left join [dbo].[EQ_EQUIPMENT] equipment (nolock) on equipment.[ID] = mntPlanLinkedEquip.[EQID]
      left join [dbo].[EQ_MODELS] equipmentModels (nolock) on equipmentModels.[ID] = equipment.[EQMODELID]
      left join [dbo].[EQ_TYPES] equipmentTypes (nolock) on equipmentTypes.[ID] = equipmentModels.[EQTYPEID]
      left join [dbo].[COM_DEPARTMENTS] equipmentDep (nolock) on equipmentDep.[ID] = equipment.[DEPID]
      left join [dbo].[COM_EMPLOYEE] equipmentRespEmpl (nolock) on equipmentRespEmpl.[ID] = equipment.[RESP_EMPLID]
    where
      mntPlanEquip.[VNESHID] = notifRows.[MNTPLANID] and mntPlanEquip.[EQID] = notifRows.[EQID]
    order by
      equipmentTypes.[NAME], equipmentDep.[CODE], equipment.[WORKINKPLACE]
    for xml path(''), type
  ).value('.', 'nvarchar(max)')
  from @notificationRows notifRows

  -- Verify data
  --select * from @notificationRows order by MNTPLANID

  declare @mntPlanID int, @toRecipients nvarchar(max), @ccRecipients nvarchar(max), @msgSubject nvarchar(1024), @msgBody nvarchar(max);

  declare notifMntPlanIDCursor cursor local read_only for
      select distinct MNTPLANID from @notificationRows;
  open notifMntPlanIDCursor;

  while 1=1
  begin
    fetch next from notifMntPlanIDCursor into @mntPlanID;
    if @@fetch_status != 0 break;

    set @msgBody = '';
    
    select @msgBody = @msgBody + concat(N'
      <tr class="value">
        <th style="text-align: left;"><a href="a2l://doc/?ClassLabel=mnt_plan&ID=', cast([MNTPLANID] as nvarchar(10)), '">', [OPERNAME], '</a></th>
        <th style="text-align: left;">', format([NEXTDATE], 'dd.MM.yyyy HH:mm'), '</th>
        <th style="text-align: left;">', [EQTYPENAME], '</th>
        <th style="text-align: left;">', [EQMODELNAME], '</th>
        <th style="text-align: left;"><a href="a2l://doc/?ClassLabel=eq_equipment&ID=', cast([EQID] as nvarchar(10)), '">', [EQSN], '</a></th>
        <th style="text-align: left;">', [EQTAGN], '</th>
        <th style="text-align: left;">', [EQWORKINKPLACE], '</th>
        <th style="text-align: left;">', [EQDEPCODE], '</th>
        <th style="text-align: left;">', [EQRESPEMPLNAME], '</th>
        <th style="text-align: left;">', [EQSTATENAME], '</th>
      </tr>',
      [LINKEDEQ]) -- additional <tr> rows
    from @notificationRows
    where [MNTPLANID] = @mntPlanID
    order by [NEXTDATE];
    
    select @msgBody = concat(N'<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <style type="text/css">
    .header
      {
        margin: 0px;
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
        font-size: 12px;
      }
    .segoe-small
      {
        font-family: ''Segoe UI'', Tahoma, Geneva, Verdana, sans-serif; font-size: 12px; text-indent:0pt; margin:0pt 0pt 0pt 0pt
      }
    .segoe-large
      {
        font-family: ''Segoe UI'', Tahoma, Geneva, Verdana, sans-serif; font-size: 14px; text-indent:0pt; margin:0pt 0pt 0pt 0pt
      }
    th, td
      {
        padding: 1px 5px 1px 5px;
      }
  </style>
</head>
<body>
  <p class="segoe-large">Dear All,<br><br>The following operations will soon be created based on defined maintenance plans:</p><br>
    <table style="padding: 0px; margin: 0px; border-collapse: collapse; border-spacing: 0px;" border="1" bordercolor="gray">
      <tr class="header">
        <th>Maintenance Plan</th>
        <th>Next Execution Date</th>
        <th>Equipment Type</th>
        <th>Equipment Model</th>
        <th>Equipment SN</th>
        <th>Equipment TAG Nr.</th>
        <th>Working Place</th>
        <th>Department</th>
        <th>Responsible Person</th>
        <th>State</th>
      </tr>
        ',
        @msgBody, N'
    </table><br/>
    <p class="segoe-small">This e-mail was created automatically based on settings configured by the maintenance plan owner. Please do not respond.<br/>PDB</p>
    <!-- @UserID=', isnull(cast(@UserID as nvarchar(max)), '{null}'), ' -->
    <!-- @Options=', isnull(@Options, '{null}'), ' -->
</body></html>');
    
    select top 1 @toRecipients = isnull([TORECIPIENTS], '') from @notificationRows where [MNTPLANID] = @mntPlanID;
    select top 1 @ccRecipients = [dbo].[GROUP_CONCAT_DS]([CCRECIPIENT], ';', 1) from @notificationRows where [MNTPLANID] = @mntPlanID;
    -- Remove duplicate emails from CC recipients
    select @ccRecipients = [dbo].[GROUP_CONCAT_DS]([ITEM], ';', 1) from (select distinct [ITEM] from [dbo].[COM_STR2TABLE_STR_DELIM](@ccRecipients, ';')) emails;
    select top 1 @msgSubject = 'Maintenance Plan Notification - ' + [OPERNAME] from @notificationRows where [MNTPLANID] = @mntPlanID;
    
    if (len(@toRecipients) > 0 or len(@ccRecipients) > 0)
    begin
      exec MSG_SEND2 @UserID, @toRecipients, @ccRecipients, @msgSubject, @msgBody;
    end
  end

  close notifMntPlanIDCursor;
  deallocate notifMntPlanIDCursor;

  -- Save last notification send date
  merge [dbo].[COM_SYSSETTINGS] as target
  using (
    select
      'mnt_last_send_notifications_planned' as [LABEL],
      'Last send date for notifications about planned equipment maintenance' as [DESC],
      getdate() as [VALUEDATE]
    ) as source
  on target.[LABEL] = source.[LABEL]
  when matched then update set [VALUEDATE] = source.VALUEDATE
  when not matched then insert ([LABEL], [DESC], [VALUEDATE]) values (source.[LABEL], source.[DESC], source.[VALUEDATE]);

  set nocount off

END