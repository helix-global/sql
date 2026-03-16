--AZURE6030:2025-08-20: Removed useless parameters. Added @Options parameter.Refactored.
--KB4583:2024-02-08:Using "Notification 'Components Shipped'" delivery list for specifed departments.
CREATE PROCEDURE [dbo].[FC_NOTIFICATION_FOC1] @DepID int,@Options nvarchar(max)=null
AS
BEGIN
  set nocount on
  declare @OptionsT table ([OPTION] nvarchar(max))
  insert into @OptionsT select [ITEM] from [dbo].[COM_STR2TABLE_STR](@Options)

  declare @numb_of_email_today int
  declare @numb_of_comp_req_analysis int
  declare @numb_of_comp_req_analysis_auth int
  declare @now datetime
  declare @yesterday datetime
  declare @componets_shipped_yesterday nvarchar(4000)
  declare @numb_of_componets_shipped_yesterday int
  declare @numb_of_componets_shipped_by_YLA int
  declare @numb_of_componets_shipped_by_YMA int
  declare @numb_of_componets_shipped_by_PLA int
  declare @subject nvarchar(100)
  declare @body nvarchar(4000)
  declare @depCode nvarchar(50)
  declare @ccS nvarchar(max)
  declare @toS nvarchar(max)
  declare @ccT table([EMPID] int primary key clustered,[EMAIL] nvarchar(max))
  declare @toT table([EMPID] int primary key clustered,[EMAIL] nvarchar(max))
  declare @EmpID int
  declare @NoSend int = 0
  declare @IgnoreRestrictions int = 0

  if exists(select * from @OptionsT where [OPTION] like 'IgnoreRestrictions') set @IgnoreRestrictions = 1
  if exists(select * from @OptionsT where [OPTION] like 'NoSend')             set @NoSend = 1

  SET @now = getdate()
  SET @now = cast (@now as date)

  SET @ccS=N''

  select
    @depCode = [dep].[CODE]
  from [dbo].[COM_DEPARTMENTS] [dep] with(nolock)
  where [dep].[ID] = @DepID

  set @subject='Components shipped ('+@depCode+')'
    --print @subject

  declare @dayOfWeek int
  set @dayOfWeek = (@@datefirst+datepart(weekday,@now)-2)%7+1; 

  select
    @yesterday = case when @dayOfWeek = 1 then @now - 3
      else @now - 1 end

  set @yesterday = cast(@yesterday as date)

  select @numb_of_email_today=count(*)
  from [dbo].[MSG_OUTGOING]
  where [MSGSUBJ] = @subject
    and convert(date,[S_CDT])=convert(date,getdate())
    and [MSGDELIVERYID] = 1

  if (@numb_of_email_today > 0) and (@IgnoreRestrictions=0)
  begin
    set nocount off
    return
  end

  declare @models table ([ID] int primary key clustered)
  insert into @models ([ID])
    select distinct [mdl].[ID]
    from [PR_MODELS] [mdl] with(nolock)
    where [mdl].[TYPEID] in (select [ID] from [dbo].[PR_DEP_MODELTYPES](@DepID))
  /*select ID from dbo.PR_DEP_MODELS(@DepID) */ /*05.11.2018 включены R модели немецких типов моделей*/
      and (@DepID <> 137 or [mdl].[DEPID] = 137)  /*KB2966*/

  select @numb_of_componets_shipped_yesterday=count(*)
  from [dbo].[FC_REPORT] [rep] with(nolock)
  where [rep].[MODELID] in (select [ID] from @models)
    and cast([rep].[USER1DT] as date) = @yesterday

  if (@numb_of_componets_shipped_yesterday < 1) and (@IgnoreRestrictions=0)
  begin
    set nocount off
    return
  end

  insert into @ccT
    select
       [e].[ID]
      ,[e].[EMAIL]
    from [dbo].[MSG_DELIVERYLIST] [a] with(nolock)
      inner join [dbo].[MSG_DELIVERYLIST_T] [b] with(nolock) on [b].[VNESHID]=[a].[ID]
      inner join [dbo].[COM_EMPLOYEE]       [e] with(nolock) on [e].[ID]=[b].[EMPLID]
    where [a].[DELIVERYTYPE]=2411 -- "Notification 'Components Shipped'" {pdb://enum?EnumTypeOID=1000112&EnumMemberOID=1000959}
      and [b].[EMPCOPY]=1
      and len([e].[EMAIL]) > 0
      and [a].[DEPID]=@DepID

  insert into @toT
    select
       [e].[ID]
      ,[e].[EMAIL]
    from [dbo].[MSG_DELIVERYLIST] [a] with(nolock)
      inner join [dbo].[MSG_DELIVERYLIST_T] [b] with(nolock) on [b].[VNESHID]=[a].[ID]
      inner join [dbo].[COM_EMPLOYEE]       [e] with(nolock) on [e].[ID]=[b].[EMPLID]
    where [a].[DELIVERYTYPE]=2411 -- "Notification 'Components Shipped'" {pdb://enum?EnumTypeOID=1000112&EnumMemberOID=1000959}
      and isnull([b].[EMPCOPY],0)=0
      and len([e].[EMAIL]) > 0
      and [a].[DEPID]=@DepID

  if not exists(select * from @toT)
  begin
    set @EmpID = null
    select top 1
      @EmpID=[e].[ID]
    from @ccT [a]
      inner join [dbo].[COM_EMPLOYEE] [e] with(nolock) on [e].[ID]=[a].[EMPID]
    where [e].[ROLEINDEP] in (10,100) -- "Deputy" or "Head of department"
    order by [e].[ROLEINDEP] desc

    if @EmpID is not null
    begin
      insert into @toT
        select
           [a].[EMPID]
          ,[a].[EMAIL]
        from @ccT [a]
        where [a].[EMPID]=@EmpID

      delete from @ccT where [EMPID]=@EmpID
    end
  end

  select @ccS=[dbo].[GROUP_CONCAT_D]([a].[EMAIL],';') from @ccT [a]
  select @toS=[dbo].[GROUP_CONCAT_D]([a].[EMAIL],';') from @toT [a]

  print '@ccS='''+@ccS+''''
  print '@toS='''+@toS+''''

  select @numb_of_componets_shipped_by_YLA=count(*)
  from [dbo].[FC_REPORT] [rep] with(nolock)
  where [rep].[MODELID] in (select [ID] from @models)
    and cast([rep].[USER1DT] as date) = @yesterday
    and [rep].[FROMDEPID] = 195 /*YLA*/

  print '@numb_of_componets_shipped_by_YLA='+format(@numb_of_componets_shipped_by_YLA,'d')

/*
  IF @numb_of_componets_shipped_by_YLA > 0
  SET @cc = @cc + ';CWSM@ipgphotonics.com'
*/

  select @numb_of_componets_shipped_by_YMA=count(*) 
  from [dbo].[FC_REPORT] [rep] with(nolock)
  where [rep].[MODELID] in (select [ID] from @models)
    and cast([rep].[USER1DT] as date) = @yesterday
    and [rep].[FROMDEPID] = 196 /*YMA*/
  print '@numb_of_componets_shipped_by_YMA='+format(@numb_of_componets_shipped_by_YMA,'d')

  select @numb_of_componets_shipped_by_PLA=count(*) 
  from [dbo].[FC_REPORT] [rep] with(nolock)
  where [rep].[MODELID] in (select [ID] from @models)
    and cast([rep].[USER1DT] as date) = @yesterday
    and [rep].[FROMDEPID] = 170 /*PLA*/
  print '@numb_of_componets_shipped_by_PLA='+format(@numb_of_componets_shipped_by_PLA,'d')

  select @componets_shipped_yesterday = isnull(@componets_shipped_yesterday,'') + ',<br>' 
     + isnull([dep].[CODE],'') + ': ID:' + convert(varchar,[rep].[ID]) + ' ' + isnull([mdl].[NAME],'') + ' SN:' + isnull([rep].[SN],'') 
  from [dbo].[FC_REPORT] [rep] with(nolock)
    left join [dbo].[PR_MODELS]       [mdl] with(nolock) on [mdl].[ID]=[rep].[MODELID]
    left join [dbo].[COM_DEPARTMENTS] [dep] with(nolock) on [dep].[ID]=[rep].[FROMDEPID]
  where [rep].[MODELID] in (select [ID] from @models)
    and cast([rep].[USER1DT] as date) = @yesterday
  print '@componets_shipped_yesterday='+isnull(''''+@componets_shipped_yesterday+'''','null')

  select @numb_of_comp_req_analysis = count(*)
  from [dbo].[FC_REPORT] [rep] with(nolock)
  where [rep].[MODELID] in (select [ID] from @models)
    and [rep].[REQUESTEDACTIONS] in (1,2,6)
    and [rep].[USER2DT] is null
    and [rep].[USER1DT] is not null
    and [rep].[USER1DT] <= @now
    and [rep].[S_S] = 1
  print '@numb_of_comp_req_analysis='+format(@numb_of_comp_req_analysis,'d')

  select @numb_of_comp_req_analysis_auth=count(*) 
  from [dbo].[FC_REPORT] [rep] with(nolock)
  where [rep].[MODELID] in (select [ID] from @models)
    and [rep].[REQUESTEDACTIONS] in (1,2,6)
    and [rep].[S_S] = 1000103
  print '@numb_of_comp_req_analysis_auth='+format(@numb_of_comp_req_analysis_auth,'d')

  set @componets_shipped_yesterday = SUBSTRING(@componets_shipped_yesterday, 6, 4994)
  if @componets_shipped_yesterday is not null and len(@componets_shipped_yesterday)>0
  begin
    set @body='Hello,<br><br>'
    set @body=@body + 'yesterday on ' + convert(varchar, @yesterday, 104) + ' following components were shipped to you:<br><br>'
    set @body=@body + isnull(@componets_shipped_yesterday,'') + '<br><br>'
    set @body=@body + 'There are ' + convert(varchar,@numb_of_comp_req_analysis) +' ' + @depCode + ' FBs need your failure analysis.<br>'
    set @body=@body + 'There are ' + convert(varchar,@numb_of_comp_req_analysis_auth) + ' ' + @depCode + ' FBs need your analysis approval.<br>'
    set @body=@body + 'Please, do not answer this e-mail.<br><br>'
    set @body=@body + 'Production Database'

    if @NoSend=0
    begin
      insert into [dbo].[MSG_OUTGOING] ([S_S],[GID],[MSGTO],[MSGSUBJ],[MSGBODY],[S_CDT],[S_CR],[MSGDELIVERYID],[MSGCC])
      values (1, newid(), @toS, @subject, @body, getdate(), 0, 1, @ccS)
    end
  end
END