--KB4879:2024-07-26: Added course link.
--KB4817:2024-05-29: Forced sending of the message. Added additional procedure arguments.
--KB3106:2022-10-11: n1. Отправка уведомления руководителю отдела и сотруднику ( если указан email в карточке Employee ),
--                   если тренинг не пройден сотрудником и до даты указанной в "Due date" остался один день ( Pic 2 )
CREATE PROCEDURE [dbo].[IOE_KB3106SENDNOTIFICATION] @UserID int, @aMode int,@ProgID int = 0, @Options nvarchar(max)=null
AS
BEGIN
  set nocount on
  declare @OptionsT table ([OPTION] nvarchar(max))
  insert into @OptionsT select [ITEM] from [dbo].[COM_STR2TABLE_STR](@Options)

  declare @HtmlBody nvarchar(max)
  declare @CourseName nvarchar(max),@Employee nvarchar(max)
  declare @DueDate nvarchar(max)
  declare @NL nvarchar(max)
  declare @Link nvarchar(max) = null
  declare @now datetime = getdate()
  declare @IgnoreRestrictions int = 0
  declare @Trace int = 0
  declare @NoSend int = 0

  if exists(select * from @OptionsT where [OPTION] like 'IgnoreRestrictions') set @IgnoreRestrictions = 1
  if exists(select * from @OptionsT where [OPTION] like 'Trace')              set @Trace = 1
  if exists(select * from @OptionsT where [OPTION] like 'NoSend')             set @NoSend = 1

  if @Trace=1
  begin
    insert into [dbo].[DEF_LOG] ([DD],[LEV],[CAPTION],[S_USERID],[EV_TYPE],[DOCOID],[DOCID],[EV_TEXT])
        values (getdate(),1,'trace:{[dbo].[IOE_KB3106SENDNOTIFICATION]}',
            @UserID,-1,null,null,
                'Entry point:'+nchar(13)+nchar(10) +
                'exec [dbo].[IOE_KB3106SENDNOTIFICATION]'+nchar(13)+nchar(10)+
                '   @UserID='   + isnull(cast(@UserID as varchar(max)),'null')+nchar(13)+nchar(10)+
                '  ,@aMode='    + isnull(cast(@aMode as varchar(max)),'null')+nchar(13)+nchar(10)+
                '  ,@ProgID='    + isnull(cast(@ProgID as varchar(max)),'null')+nchar(13)+nchar(10)+
                '  ,@Options='  + isnull('N'''+@Options+'''','null'))
  end

  if ((datepart(hour,@now) not in (8,9,10,11)) and (@IgnoreRestrictions=0)) or (@NoSend=1)
  begin
    set nocount off
    return
  end

  declare @nowDate date = CAST(@now as date)
  declare @needNotify table(ID int not null)
  insert into @needNotify(ID)
    select A.ID
    from IOE_PROGRESS A with(nolock)
      left join IOE_TRAINING B with(nolock) on B.ID = A.TRAININGID
      left join COM_EMPLOYEE C with(nolock) on C.ID = A.EMPLID
     where A.S_S <> 2130064/*completed*/
       and ((B.EXPIREDDD is not null) or (@IgnoreRestrictions=1))
       and ((dateadd(day,-1,cast(B.EXPIREDDD as date)) = @nowDate) or (@IgnoreRestrictions=1))
       and ((A.KB3106NOTIFIED is null) or (@IgnoreRestrictions=1))
       and ((@ProgID=0) or (A.ID=@ProgID))

  if @@rowcount = 0
  begin
    print N'No information could be sent according to the specified criteria.'
    set nocount off
    return
  end

    set @NL = nchar(13) + nchar(10)
    set @HtmlBody = N'Dear All,<br/>The following IoE course <b>expiration date coming soon</b>:<br/><br/>'
      + N'<p class="segoe" style="font-size: 9"><table style="padding: 0px; margin: 0px; border-collapse: collapse; border-spacing: 0px;" border="1" bordercolor="red">
            <tr>
              <td class="header" style="border-color: #134a8f #134a8f white #134a8f;">Course Name</td>
              <td class="value">%CourseName%</td>
            </tr>
            <tr>
              <td class="header">Employee</td>
              <td class="value">%Employee%</td>
            </tr>
            <tr>
              <td class="header">Link</td>
              <td class="value"><a href="%LINK%">%LINK%</a></td>
            </tr>
            <tr>
              <td class="header" style="border-color: white #134a8f #134a8f #134a8f;">Due Date</td>
              <td class="value">%DueDate%</td>
            </tr>
          </table></p><br/><p class="segoe">This e-mail was created automatically. Please do not respond.<br/>PDB</p>'
    set @HtmlBody = N'<p class="segoe">' + @HtmlBody + N'</p>'
    set @HtmlBody =
             N'<!--@UserID='  + isnull(cast(@UserID as nvarchar(max)),'{null}') + N'-->'
     + @NL + N'<!--@aMode='   + isnull(cast(@aMode as nvarchar(max)), '{null}') + N'-->'
     + @NL + N'<!--@ProgID='  + isnull(cast(@ProgID as nvarchar(max)),'{null}') + N'-->'
     + @NL + N'<!--@Options=' + isnull(@Options, '{null}') + N'-->'
     + @NL + @HtmlBody
    set @HtmlBody = N'<html xmlns="http://www.w3.org/1999/xhtml">
      <head>
        <style type="text/css">
          .header
            {
            padding: 0px 5px 0px 5px; margin: 0px;
            border-style: solid; border-width: 1px;
            border-color: white #134a8f white #134a8f;
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

  declare @prID int

  declare nxx cursor local read_only for 
  select distinct ID from @needNotify
  open nxx 
  while 1=1
  begin
      fetch next from nxx into @prID
      if @@FETCH_STATUS<>0 break;

      declare @HtmlBodyN nvarchar(max)
      declare @toCC nvarchar(1024) = null
      declare @depID int = null

      select
         @toCC = C.EMAIL
        ,@depID = C.DEPID
        ,@CourseName=D.NAME
        ,@Employee=C.NAME
        ,@DueDate=isnull(convert(nvarchar(max),B.EXPIREDDD,23),N'?')
        ,@Link=N'https://training.ipgphotonics.com/#/course/' + cast([a].[GID] as nvarchar(max))
      from [dbo].[IOE_PROGRESS] [a] with(nolock)
        left join [dbo].[IOE_TRAINING] B with(nolock) on B.ID = [a].TRAININGID 
        left join [dbo].[COM_EMPLOYEE] C with(nolock) on C.ID = [a].EMPLID
        left join [dbo].[IOE_TOPICS]   D with(nolock) on D.ID = B.TOPICID
      where [a].ID = @prID

      set @Link = isnull(@Link,N'https://training.ipgphotonics.com/#/mycourses')
      set @HtmlBodyN = @HtmlBody
      set @HtmlBodyN = replace(@HtmlBodyN,'%LINK%',@Link)
      set @HtmlBodyN = replace(@HtmlBodyN,'%DueDate%',@DueDate)
      set @HtmlBodyN = replace(@HtmlBodyN,'%Employee%',@Employee)
      set @HtmlBodyN = replace(@HtmlBodyN,'%CourseName%',@CourseName)

      /*
      set @HtmlBodyN = @HtmlBodyN + N'<br>'+isnull(@toCC,'NA')  
      exec MSG_SEND2 @UserID, 'dnorkin@ipgphotonics.com', null, 'IoE Due Date Coming Soon', @HtmlBodyN
      exec MSG_SEND2 @UserID, 'damaistrenko@ipgphotonics.com', null, 'IoE Due Date Coming Soon', @HtmlBodyN
      */
      exec MSG_SEND_TODEP_HEADS @UserID, @depID, @toCC, 1, 'IoE Course Due Date Coming Soon', @HtmlBodyN

      update IOE_PROGRESS set KB3106NOTIFIED = @now where ID = @prID
  end
  close nxx;
  deallocate nxx;

  set nocount off
END