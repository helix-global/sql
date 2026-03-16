-- Stored procedure to send notifications about expired operations for equipment maintenance.
-- Old procedures - see MNT_NOTIFICATION_FUTURE2, MNT_NOTIFICATION_PART2, functions MNT_NOTIFICATION_HTMLROW, MNT_NOTIFICATION_HTMLROW_EXP etc - are not used anymore.
--
-- History of changes:
-- KB4734     2025-10-17 New stored procedure is created for new logic (see task description).
-- Azure#6138 2025-11-10 Add equipment responsible person to CC
--
-- Test: EXEC [dbo].[MNT_SEND_NOTIFICATIONS_EXPIRED] 1620 /*IPGL-PDB-Agent*/, 'IgnoreRestrictions'
-- Test: EXEC [dbo].[MNT_SEND_NOTIFICATIONS_EXPIRED] 1620 /*IPGL-PDB-Agent*/, 'IgnoreRestrictions,AssumeTodayIsSunday'
CREATE   PROCEDURE [dbo].[MNT_SEND_NOTIFICATIONS_EXPIRED]
  @UserID int,
  @options nvarchar(max) = null
as
begin
  set nocount on

  declare @ignoreRestrictions int = 0,
    @now datetime = getdate(),
    @nowDate date = cast(getdate() as date),
    @lastSend datetime = (select top 1 [VALUEDATE] from [dbo].[COM_SYSSETTINGS] (nolock) where [LABEL] = 'mnt_last_send_notifications_expired'),
    @lastSendDate date = (select top 1 cast([VALUEDATE] as date) from [dbo].[COM_SYSSETTINGS] (nolock) where [LABEL] = 'mnt_last_send_notifications_expired');

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

  declare @expiredOpers table (OPERID int, MNTPLANID int);
  
  insert into @expiredOpers (OPERID, MNTPLANID)
  select
    oper.[ID],
    oper.[MNT_PLANID]
  from
    [dbo].[PR_OPERATION] oper (nolock) 
    join [dbo].[MNT_PLAN] mntPlan (nolock) on mntPlan.[ID] = oper.[MNT_PLANID]
  where
    oper.[MNT_PLANID] is not null
    and oper.[COMPLETED_DT] is null
    and oper.[S_S] in (1000031 /*In Progress*/, 1000032 /*Pending*/, 1000033 /*Postponed*/)
    and mntPlan.[S_S] = 1
    and mntPlan.[NOTIFICATIONEXP_DAYS] > 0
    and datediff(day, cast(oper.[S_CDT] as date), @nowDate) >= 1
    and
    (
      (
        (
          (mntPlan.[NOTIFICATIONEXP_EVRDAY] = 1)
          or
          (isnull(mntPlan.[WEEKLY_ONLY], 0) = 1 and @todayIsSunday = 1) -- Ignore "evday" for mnt. plans with "Include in Weekly Report Only" flag
        )
        and
        (datediff(day, oper.[S_CDT], @now) >= mntPlan.[NOTIFICATIONEXP_DAYS])
      )
      or
      (
        mntPlan.[NOTIFICATIONEXP_EVRDAY] = 0 and datediff(day, oper.[S_CDT], @now) % mntPlan.[NOTIFICATIONEXP_DAYS] = 0 -- Not every day but every EXP_DAYS
      )
    )
    and
    (
      isnull(mntPlan.[WEEKLY_ONLY], 0) = 0
      or
      @todayIsSunday = 1
    )

    -- Verify data
    --select * from @expiredOpers

/* Maintenance Plan      Operation Date        Equipment Type    Equipment Model     Equipment SN    Equipment TAG Nr.   Working Place      Department    Responsible Person    State   Remark
Test Module Maintenance  05.09.2025 15:32      Test Setup        PLD-212 Setup       20056823        NA                  CB28 Raum2_Tisch5  FBA-YFB_G     Grigorii Bashkirov    In Use  END-Test Kalibrierung April */

  declare @notificationRows table (MNTPLANID int, OPERNAME nvarchar(100), OPERID int, OPERDATE datetime,
    EQID int, EQTYPENAME nvarchar(200), EQMODELNAME nvarchar(100), EQSN nvarchar(100), EQTAGN nvarchar(100),
    EQWORKINKPLACE nvarchar(50), EQDEPCODE nvarchar(100), EQRESPEMPLNAME nvarchar(200), EQSTATENAME nvarchar(150), EQREMARK ntext,
    LINKEDEQ nvarchar(max),
    TORECIPIENTS nvarchar(max), CCRECIPIENT nvarchar(max))

  insert into @notificationRows (MNTPLANID, OPERNAME, OPERID, OPERDATE,
    EQID, EQTYPENAME, EQMODELNAME, EQSN, EQTAGN, EQWORKINKPLACE, EQDEPCODE, EQRESPEMPLNAME, EQSTATENAME, EQREMARK,
    TORECIPIENTS, CCRECIPIENT)
  select
    mntPlan.[ID],
    expiredOperType.[NAME] as [OPERNAME],
    expiredOper.[ID] as [OPERID],
    expiredOper.[S_CDT] as [OPERDATE],
    mntPlanEquip.[EQID],
    equipmentTypes.[NAME] as [EQTYPENAME],
    equipmentModels.[CODE] as [EQMODELNAME],
    equipment.[SN] as [EQSN],
    equipment.[TAGN] as [EQTAGN],
    equipment.[WORKINKPLACE] as [EQWORKINKPLACE],
    equipmentDep.[CODE] as [EQDEPCODE],
    equipmentRespEmpl.[NAME] as [EQRESPEMPLNAME],
    dbo.DEF_STATE_NAME_EN(equipment.[S_S]) as [EQSTATENAME],
    equipment.[REMARK] as [EQREMARK],
    ( select
        [dbo].[GROUP_CONCAT_DS](distinct empl.[EMAIL], ';', 1)
      from [dbo].[COM_EMPLOYEE] empl (nolock)
      join [dbo].[MNT_PLAN_NOTYRCV] mntNotifRecipients (nolock) on empl.[ID] = mntNotifRecipients.[EMPLID]
      where empl.[S_S] = 1 /* only active employees */ and mntNotifRecipients.[VNESHID] = mntPlan.[ID]
    ) as [TORECIPIENTS],
    ( case
        when expiredOperEmployee.[S_S] = 1 then expiredOperEmployee.[EMAIL] + ';'
        else ';'
      end
      +
      case
        when equipmentRespEmpl.[S_S] = 1 then equipmentRespEmpl.[EMAIL]
        else ''
      end
    ) as [CCRECIPIENT]
  from
    @expiredOpers expired
    join [dbo].[MNT_PLAN] mntPlan (nolock) on mntPlan.[ID] = expired.[MNTPLANID]
    join [dbo].[PR_OPERATION] expiredOper (nolock) on expiredOper.[ID] = expired.[OPERID]
    join [dbo].[PR_OPERATIONS] expiredOperType (nolock) on expiredOperType.[ID] = expiredOper.[OPERTYPEID]
    left join [dbo].[DEF_USERS] expiredOperUser (nolock) on expiredOperUser.[ID] = expiredOper.[USERINPROGRESS]
    left join [dbo].[COM_EMPLOYEE] expiredOperEmployee (nolock) on expiredOperEmployee.[ID] = expiredOperUser.[EMPLOYEEID]
    left join [dbo].[MNT_PLAN_EQ] mntPlanEquip (nolock) on mntPlanEquip.[VNESHID] = mntPlan.[ID] and mntPlan.[CRMODE] in (3, 4) and mntPlanEquip.[EQID] = expiredOper.[EQID]
    left join [dbo].[EQ_EQUIPMENT] equipment (nolock) on equipment.[ID] = mntPlanEquip.[EQID]
    left join [dbo].[EQ_MODELS] equipmentModels (nolock) on equipmentModels.[ID] = equipment.[EQMODELID]
    left join [dbo].[EQ_TYPES] equipmentTypes (nolock) on equipmentTypes.[ID] = equipmentModels.[EQTYPEID]
    left join [dbo].[COM_DEPARTMENTS] equipmentDep (nolock) on equipmentDep.[ID] = equipment.[DEPID]
    left join [dbo].[COM_EMPLOYEE] equipmentRespEmpl (nolock) on equipmentRespEmpl.[ID] = equipment.[RESP_EMPLID]
  where
    mntPlan.[CRMODE] in (1, 2)
    or dbo.MNT_EQ_STATE_CHECK(equipment.[S_S], mntPlan.[EQINNOTIFICATION]) = 1

  -- Description of linked equipment: extra lines (or nothing if there are no linked EQs) under each equipment line.
  update notifRows
  set [LINKEDEQ] =
  (
    select concat(N'
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
        <th style="text-align: left;">', equipment.[REMARK], '</th>
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
        <th style="text-align: left;"><a href="a2l://doc/?ClassLabel=pr_device_operation&ID=', cast([OPERID] as nvarchar(10)), '">', format([OPERDATE], 'dd.MM.yyyy HH:mm'), '</a></th>
        <th style="text-align: left;">', [EQTYPENAME], '</th>
        <th style="text-align: left;">', [EQMODELNAME], '</th>
        <th style="text-align: left;"><a href="a2l://doc/?ClassLabel=eq_equipment&ID=', cast([EQID] as nvarchar(10)), '">', [EQSN], '</a></th>
        <th style="text-align: left;">', [EQTAGN], '</th>
        <th style="text-align: left;">', [EQWORKINKPLACE], '</th>
        <th style="text-align: left;">', [EQDEPCODE], '</th>
        <th style="text-align: left;">', [EQRESPEMPLNAME], '</th>
        <th style="text-align: left;">', [EQSTATENAME], '</th>
        <th style="text-align: left;">', [EQREMARK], '</th>
      </tr>',
      [LINKEDEQ]) -- additional <tr> rows
    from @notificationRows
    where [MNTPLANID] = @mntPlanID
    order by [OPERDATE];
    
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
  <p class="segoe-large">Dear All,<br><br>The following operations were created based on maintenance plans and they are <span style="color: red; font-weight: bold;">not completed yet</span>:</p><br>
    <table style="padding: 0px; margin: 0px; border-collapse: collapse; border-spacing: 0px;" border="1" bordercolor="gray">
      <tr class="header">
        <th>Maintenance Plan</th>
        <th>Expired Operation Date</th>
        <th>Equipment Type</th>
        <th>Equipment Model</th>
        <th>Equipment SN</th>
        <th>Equipment TAG Nr.</th>
        <th>Working Place</th>
        <th>Department</th>
        <th>Responsible Person</th>
        <th>State</th>
        <th>Remark</th>
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
    select top 1 @msgSubject = 'Expired Maintenance Plan Notification - ' + [OPERNAME] from @notificationRows where [MNTPLANID] = @mntPlanID;
    
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
      'mnt_last_send_notifications_expired' as [LABEL],
      'Last send date for notifications about expired equipment maintenance operations' as [DESC],
      getdate() as [VALUEDATE]
    ) as source
  on target.[LABEL] = source.[LABEL]
  when matched then update set [VALUEDATE] = source.VALUEDATE
  when not matched then insert ([LABEL], [DESC], [VALUEDATE]) values (source.[LABEL], source.[DESC], source.[VALUEDATE]);

  set nocount off
END