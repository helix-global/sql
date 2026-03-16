--KB4879:2024-07-26: Color theme change.
--KB4516:2023-01-05: Status change event handler for "ioe_training". {Maistrenko}
--KB4560:2023-01-22: Fix empty link field in message body "ioe_training". {Maistrenko}
CREATE procedure [dbo].[IOE_KB4516SENDNOTIFICATION] @UserID int,@ContextID int,@S_S_OLD int,@S_S_NEW int, @S_MR_NEW int
as
begin
  declare @HtmlBody nvarchar(max),@PlaneBody nvarchar(max)
  declare @RecipientEmployeeId int,@DepId int,@TopicId int
  declare @CC nvarchar(max)
  declare @Subject nvarchar(max) = 'IoE Courses assigned'
  declare @CourseName nvarchar(max)
  declare @DueDate nvarchar(max)
  declare @InstructorsNames nvarchar(max)
  declare @InstructorsEMails nvarchar(max)
  declare @Remark nvarchar(max)
  declare @Link nvarchar(max) = null
  declare @NL nvarchar(max)

  set nocount on
  select top 1
     @CourseName=isnull([b].[NAME],N'?')
    ,@DueDate=isnull(convert(nvarchar(max),[a].[EXPIREDDD],23),N'?')
    ,@Remark=isnull([a].[REMARK],N'')
    ,@DepId=[a].[DEPID]
    ,@TopicId=[a].[TOPICID]
    ,@InstructorsNames=isnull((
          select [dbo].[GROUP_CONCAT_D]([E].[NAME],N';')
          from [dbo].[IOE_TOPIC_INSTRUCTORS] [i] with(nolock)
            left join [dbo].[COM_EMPLOYEE] [E] with(nolock) on [E].[ID]=[i].[EMPLID]
          where [i].[VNESHID]=[b].[ID]),N'')
    ,@InstructorsEMails=(
          select [dbo].[GROUP_CONCAT_D]([E].[EMAIL],N';')
          from [dbo].[IOE_TOPIC_INSTRUCTORS] [i] with(nolock)
            left join [dbo].[COM_EMPLOYEE] [E] with(nolock) on [E].[ID]=[i].[EMPLID]
          where [i].[VNESHID]=[b].[ID])
  from [dbo].[IOE_TRAINING] [a] with(nolock)
    left join [dbo].[IOE_TOPICS] [b] with(nolock) on [b].[ID]=[a].[TOPICID]
  where [a].[ID]=@ContextID

  set @NL = nchar(13) + nchar(10)
  if @S_S_NEW=2130061
  begin
    declare @Recipients TABLE([EMPLID] int)
    insert into @Recipients
      select [e].[EMPLID]
      from [dbo].[IOE_TRAINING] [a] with(nolock)
        inner join [dbo].[IOE_TRAINING_EMPL] [e] with(nolock) on [e].[VNESHID]=[a].[ID]
      where [a].[ID]=@ContextID

    set @PlaneBody = N'You have been assigned a course:' + @NL
      + @NL + N'Course: '      + @CourseName
      + @NL + N'Instructors: ' + @InstructorsNames
      + @NL + N'Due Date: '    + @DueDate
      + @NL + N'Link: %LINK%'
      + @NL + N'Remark: '      + @Remark

    set @HtmlBody = N'You have been assigned a course:<br/><br/>'
      + N'<p class="segoe" style="font-size: 9"><table style="padding: 0px; margin: 0px; border-collapse: collapse; border-spacing: 0px;" border="1" bordercolor="red">
            <tr>
              <td class="header" style="border-color: #134a8f #134a8f white #134a8f;">Course</td>
              <td class="value">'+@CourseName + '</td>
            </tr>
            <tr>
              <td class="header">Instructors</td>
              <td class="value">' + @InstructorsNames + '</td>
            </tr>
            <tr>
              <td class="header">Due Date</td>
              <td class="value">' + @DueDate + '</td>
            </tr>
            <tr>
              <td class="header">Link</td>
              <td class="value"><a href="%LINK%">%LINK%</a></td>
            </tr>
            <tr>
              <td class="header" style="border-color: white #134a8f #134a8f #134a8f;">Remark</td>
              <td class="value">' + @Remark + '</td>
            </tr>
          </table></p><br/><p class="segoe">This e-mail was created automatically. Please do not respond.<br/>PDB</p>'
    set @HtmlBody = N'<p class="segoe">' + @HtmlBody + N'</p>'
    set @HtmlBody =
             N'<!--@UserID='    + isnull(cast(@UserID as nvarchar(max)),   '{null}') + N'-->'
     + @NL + N'<!--@S_S_OLD='   + isnull(cast(@S_S_OLD as nvarchar(max)),  '{null}') + N'-->'
     + @NL + N'<!--@S_S_NEW='   + isnull(cast(@S_S_NEW as nvarchar(max)),  '{null}') + N'-->'
     + @NL + N'<!--@S_MR_NEW='  + isnull(cast(@S_MR_NEW as nvarchar(max)), '{null}') + N'-->'
     + @NL + N'<!--@ContextID=' + isnull(cast(@ContextID as nvarchar(max)),'{null}') + N'-->'
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

    declare @MessageId int
    declare [c] cursor local read_only for select distinct [EMPLID] from @Recipients
    open [c]
      fetch next from [c] INTO @RecipientEmployeeId
      while @@FETCH_STATUS=0
      begin
        declare @HtmlBodyN nvarchar(max),@PlaneBodyN nvarchar(max)
        --set @CC = @InstructorsEMails -- They were supposed to add instructors to the copy. But then they decided not to do it.
        set @CC = N''
        select top 1
          @Link=N'https://training.ipgphotonics.com/#/course/' + cast([a].[GID] as nvarchar(max))
        from [dbo].[IOE_PROGRESS] [a] with(nolock)
        where ([a].[EMPLID]=@RecipientEmployeeId)
          and ([a].[TOPIC]=@TopicId)

        set @Link = isnull(@Link,N'https://training.ipgphotonics.com/#/mycourses')

        set @HtmlBodyN  = replace(@HtmlBody,'%LINK%',@Link)
        set @PlaneBodyN = replace(@PlaneBody,'%LINK%',@Link)
        exec MSG_SEND_TOEMPLOYEE2 @UserID,@RecipientEmployeeId,@CC,@Subject,@HtmlBodyN

        insert into [dbo].[COM_SPV_MESSAGE]([GID],[S_S],[S_CR],[S_CDT],[DD],[MESS],[DEPID],[UPVISIBLE])
        values (NEWID(),1,@UserID,GETDATE(),GETDATE(),@PlaneBodyN,@DepId,1)
        set @MessageId=@@IDENTITY
        insert into [dbo].[COM_MESSAGE_EMPL]([GID],[S_CR],[S_CDT],[VNESHID],[EMPLID]) values (NEWID(),@UserID,GETDATE(),@MessageId,@RecipientEmployeeId)
        update [dbo].[COM_SPV_MESSAGE]
          set [S_S]=1000149
        where [ID]=@MessageId

        fetch next from [c] INTO @RecipientEmployeeId
      end
    close [c]
    deallocate [c]
  end
  set nocount off
end