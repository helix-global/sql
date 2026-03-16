-- Azure#6100: 2025-10-06: Include status "In Progress" for data in IOE_PROGRESS table.
-- KB4891:     2024-07-24: Forced sending of the message. Added additional procedure arguments.
--                         Prevent sending of the message for dismissed employee.
-- KB3043:     2022-03-03: Mailing to managers about IoE courses overdue.
--
-- Test: exec [dbo].[IOE_KB3043SENDNOTIFICATION] 1620 /* IPGL-PDB-Agent */, 1, 'IgnoreRestrictions'
CREATE PROCEDURE [dbo].[IOE_KB3043SENDNOTIFICATION] @UserID int, @aMode int,@Options nvarchar(max)=null
AS
BEGIN
  set nocount on
  declare @OptionsT table ([OPTION] nvarchar(max))
  insert into @OptionsT select [ITEM] from [dbo].[COM_STR2TABLE_STR](@Options)

  declare @now datetime = getdate()
  declare @IgnoreRestrictions int = 0

  if exists(select * from @OptionsT where [OPTION] like 'IgnoreRestrictions') set @IgnoreRestrictions = 1

  if (datepart(hour,@now) not in (8,9,10,11)) and (@IgnoreRestrictions=0)
  begin
    set nocount off
    print N'The message will not be sent.'
    return
  end

  declare @nowDate date
  set @nowDate = CAST(@now as date)

  declare @depID int

  select top 1 @depID = A.DEPID 
  from IOE_TRAINING A
  where A.S_S <> 2130062 /* Completed */
     and ((not exists (select * from IOE_KB3043_NOTIFICATION H where H.DEPID = A.DEPID and H.LASTSEND = @nowDate)) or (@IgnoreRestrictions=1))
     and cast(A.EXPIREDDD as date) < @nowDate
     and exists (select J.ID 
          from IOE_PROGRESS J with(nolock)
            left join COM_EMPLOYEE C with(nolock) on C.ID = J.EMPLID
          where J.TRAININGID = A.ID
            and J.S_S in (1 /* Created */, 2130063 /* In Progress */)
            and C.S_S = 1)

  if @depID is null
  begin
    set nocount off
    print N'No information about department.'
    return
  end

  declare @msgTo nvarchar(max)
  declare @HtmlBody nvarchar(max)

  set @HtmlBody = N'Dear All,<br/>'+
  N'The following courses, assigned to department contains overdue records:<br><br>'

  set @HtmlBody = @HtmlBody + '<table style="padding: 0px; margin: 0px; border-collapse: collapse; border-spacing: 0px;width:600px" border="1" bordercolor="#134a8f">
            <tr>
              <td class="header">Employee</td>
              <td class="header">Course</td>
              <td class="header" style="width: 1%;white-space: nowrap;">Due Date</td>
            </tr>'

  select @HtmlBody = @HtmlBody + '<tr><td class="value">'+C.NAME+'</td><td class="value">'+D.NAME+'</td><td class="value" style="width: 1%;white-space: nowrap;">'+convert(nvarchar,A.EXPIREDDD,104)+'</td></tr>'
  from IOE_TRAINING A with(nolock)
    left join IOE_PROGRESS B with(nolock) on B.TRAININGID = A.ID
    left join COM_EMPLOYEE C with(nolock) on C.ID = B.EMPLID
    left join IOE_TOPICS D with(nolock) on D.ID = A.TOPICID
  where A.S_S <> 2130062/*completed*/
    and A.DEPID = @depID
    and cast(A.EXPIREDDD as date) < @nowDate  /*KB3831*/
    and B.S_S in (1 /* Created */, 2130063 /* In Progress */)
    and C.S_S = 1
  order by A.EXPIREDDD desc,D.NAME,C.NAME

  set @HtmlBody = @HtmlBody+N'</table><br/>Please do not reply<br/>Production database'
  set @HtmlBody = N'<p class="segoe">' + @HtmlBody + N'</p>'
  set @HtmlBody = N'<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
      <style type="text/css">
        .header
          {
          padding: 0px 5px 0px 5px; margin: 0px; border: 1px solid #134a8f;
          color: white;
          background-color: #134a8f;
          }
        .value
          {
          padding: 0px 5px 0px 5px; margin: 0px; border: 1px solid #134a8f
          }
        .segoe
          {
          font-family: ''Segoe UI'', Tahoma, Geneva, Verdana, sans-serif; font-size: x-small;text-indent:0pt;margin:0pt 0pt 0pt 0pt
          }
      </style>
    </head>
    <body>' + @HtmlBody + N'</body></html>'

  --print @HtmlBody

  /*exec MSG_SEND2 @UserID, 'dnorkin@ipgphotonics.com', null, 'IoE Courses Overdue', @HtmlBody*/
  /*exec MSG_SEND2 @UserID, 'damaistrenko@ipgphotonics.com', null, 'IoE Courses Overdue', @HtmlBody*/
  exec MSG_SEND_TODEP_HEADS @UserID, @depID, null, 0, 'IoE Courses Overdue', @HtmlBody

  update IOE_KB3043_NOTIFICATION set LASTSEND = @nowDate where DEPID = @depID
  if @@rowcount = 0
     insert into IOE_KB3043_NOTIFICATION (DEPID,LASTSEND) values (@depID,@nowDate)

  set nocount off
END