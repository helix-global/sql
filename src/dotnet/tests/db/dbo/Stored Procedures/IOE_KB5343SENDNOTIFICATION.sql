-- KB5343: 2025-07-31: Once per week send notifications to course assignment (ioe_training) creator and head of department,
-- for topics with flag EINZELNACHWEIS_REQUIRED = 1 and employees whose progress is 'completed' and PRINTQTY (Einzelnachweis print count) = 0
--
-- Test: exec [dbo].[IOE_KB5343SENDNOTIFICATION] 1620, 'IgnoreRestrictions'
CREATE   PROCEDURE [dbo].[IOE_KB5343SENDNOTIFICATION]
	@UserID int,
	@Options nvarchar(max) = null
AS
BEGIN
  set nocount on

  declare @OptionsT table ([OPTION] nvarchar(max))
  insert into @OptionsT select [ITEM] from [dbo].[COM_STR2TABLE_STR](@Options)

  declare @IgnoreRestrictions int = 0
  if exists(select * from @OptionsT where [OPTION] like 'IgnoreRestrictions') set @IgnoreRestrictions = 1

  declare @now datetime = getdate();
  declare @nowDate datetime = cast(@now as date);
  set datefirst 1; -- set monday as day 1

  if (datepart(hour, @now) not in (8,9,10,11))
    and (datepart(weekday, @now) != 1)
    and (@IgnoreRestrictions = 0)
  begin
    set nocount off
    print N'Notification messages will not be sent due to current time period (only Mondays 8:00 - 11:59 interval is acceptable unless IgnoreRestrictions option is set).';
    return;
  end

  declare @trainingsToNotify table ([ID] int, [S_CR] int, [DEPID] int, [TOPIC_NAME] nvarchar(400), [DD] date, [EXPIREDDD] date)

  insert into @trainingsToNotify ([ID], [S_CR], [DEPID], [TOPIC_NAME], [DD], [EXPIREDDD])
  select distinct
    TRAINING.[ID], TRAINING.[S_CR], TRAINING.[DEPID], TOPIC.[NAME], TRAINING.[DD], TRAINING.[EXPIREDDD]
  from
    [dbo].[IOE_TRAINING] TRAINING (nolock)
	  join [dbo].[IOE_TOPICS] TOPIC (nolock) on TRAINING.[TOPICID] = TOPIC.[ID] and isnull(TOPIC.[EINZELNACHWEIS_REQUIRED], 0) = 1
	  join [dbo].[IOE_PROGRESS] PROGRESS (nolock) on PROGRESS.[TRAININGID] = TRAINING.[ID]
	  join [dbo].[COM_EMPLOYEE] EMPL (nolock) on EMPL.[ID] = PROGRESS.[EMPLID]
  where
	  EMPL.[S_S] != 1000092 /* Dismissed */
    and PROGRESS.[S_S] != 1000208 /* Canceled */
	  and isnull(PROGRESS.[PRINTQTY], 0) < 1 -- Einzelnachweis not printed
	  and (@IgnoreRestrictions = 1
         or TRAINING.[KB5343_LASTNOTIFIED] is null
         or datediff(day, TRAINING.[KB5343_LASTNOTIFIED], @nowDate) >= 6) -- Send notifications one time every week

  -- Debug
  --select * from @trainingsToNotify

  declare
    @reportName nvarchar(100) = (select top 1 [NAME] from [dbo].[DEF_REPORTS] where [LABEL] = 'ioe_einzelnachweis'),
    @trainingID int,
    @trainingCreatorId int,
    @trainingDepID int,
    @topicName nvarchar(400),
    @trainingDate date,
    @trainingDueDate date;

  declare trainingCursor cursor local read_only for
    select [ID], [S_CR], [DEPID], [TOPIC_NAME], [DD], [EXPIREDDD]
    from @trainingsToNotify;

  open trainingCursor;

  while 1=1
  begin
      fetch next from trainingCursor into @trainingID, @trainingCreatorId, @trainingDepID, @topicName, @trainingDate, @trainingDueDate
      if @@FETCH_STATUS != 0 break;

      declare @newLine nchar(2) = nchar(13) + nchar(10),
        @toCC nvarchar(1024) = (select top 1 EMPL.[EMAIL] from [dbo].[DEF_USERS] U (nolock) join [dbo].[COM_EMPLOYEE] EMPL (nolock) on EMPL.[ID] = U.[EMPLOYEEID] where U.[ID] = @trainingCreatorId),
        @subject nvarchar(500) = 'IoE Course status for "' + @topicName + '", Due Date ' + isnull(convert(varchar(10),@trainingDueDate,23),'none'),
        @htmlBody nvarchar(max) = concat('<p class="segoe-large">IoE assigned course <b><a href="a2l://doc/?ClassLabel=ioe_training&ID=', @trainingID, '">', @topicName, '</a></b><br/>',
          'Course Assignment: ', convert(varchar(10), @trainingDate, 23), '<br/>',
          'Course Due Date: ', isnull(convert(varchar(10), @trainingDueDate, 23), 'none'), '<br/><br/>',
          'Document "', @reportName, '" <b>is required</b> for this training but isn''t printed for some employees:</p><br/><br/>
             <table style="padding: 0px; margin: 0px; border-collapse: collapse; border-spacing: 0px;" border="1" bordercolor="gray">
               <tr class="header">
                 <th>Empl#</th>
                 <th>Employee Name</th>
                 <th>Progress Status</th>
                 <th>Remark</th>
               </tr>');

      select @htmlBody = @htmlBody +
        (
          select '
             <tr class="value">
               <th style="text-align: left;">', EMPL.[PERSONALNO], '</th>
               <th style="text-align: left;">', EMPL.[NAME], '</th>
               <th>', case when PROGRESS.[S_S] = 1 then 'Created'
                           when PROGRESS.[S_S] = 2130063 then 'In Progress'
                           when PROGRESS.[S_S] = 2130064 then 'Completed on ' + convert(nvarchar(10), PROGRESS.[COMPLETEDD], 23)
                           when PROGRESS.[S_S] = 1000208 then 'Canceled'
                           else 'Not defined'
                      end, '</th>
               <th style="text-align: left;">', @reportName + case when isnull(PROGRESS.[PRINTQTY], 0) > 0 then ' printed' else ' not printed' end,
                      case when PROGRESS.[RATINGCOMMENT] is not null then '; *** ' + left(cast(PROGRESS.[RATINGCOMMENT] as nvarchar(max)), 50)
                           else ''
                      end, '</th>
             </tr>'
          from
            [dbo].[IOE_PROGRESS] PROGRESS (nolock)
            join [dbo].[COM_EMPLOYEE] EMPL (nolock) on EMPL.[ID] = PROGRESS.[EMPLID]
          where
            PROGRESS.[TRAININGID] = @trainingID
          order by
            PROGRESS.[S_S], EMPL.[NAME]
          for xml path(''), type
        ).value('.', 'nvarchar(max)');

      set @htmlBody = concat(@htmlBody, '
             </table><br/>
             <p class="segoe-small">This e-mail was created automatically. Please do not respond.<br/>PDB</p>
             <!-- @UserID=', isnull(cast(@UserID as nvarchar(max)), '{null}'), ' -->
             <!-- @Options=', isnull(@Options, '{null}'), ' -->');

      set @htmlBody = concat('<html xmlns="http://www.w3.org/1999/xhtml">
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
                font-size: 16px;
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
                font-family: ''Segoe UI'', Tahoma, Geneva, Verdana, sans-serif; font-size: x-small; text-indent:0pt; margin:0pt 0pt 0pt 0pt
              }
            .segoe-large
              {
                font-family: ''Segoe UI'', Tahoma, Geneva, Verdana, sans-serif; font-size: 16px; text-indent:0pt; margin:0pt 0pt 0pt 0pt
              }
            th, td
              {
                padding: 1px 5px 1px 5px;
              }
          </style>
        </head>
        <body>', @htmlBody, '
        </body></html>');

      exec MSG_SEND_TODEP_HEADS @UserID, @trainingDepID, @toCC, 0 /* Mode 0 - don't swap TO and CC */, @subject, @htmlBody

      update [dbo].[IOE_TRAINING]
      set [KB5343_LASTNOTIFIED] = @now
      where [ID] = @trainingID
  end

  close trainingCursor;
  deallocate trainingCursor;

  set nocount off

END