

-- KB5247:2025-02-14: Initial Update based on [FC_ACCESS_REPORT_TAB2]
create function [dbo].[FC_ACCESS_REPORT_TAB3](@aUserID int, @aMode int, @aDate datetime)
returns @res table ([ID] int,primary key clustered ([ID]))
as
begin
  declare @ChildsT      table([CHILDID] int,primary key clustered ([CHILDID]))
  declare @DepartmentsT table([DEPID]   int,primary key clustered ([DEPID]))
  declare @ModelsT      table([MODELID] int,primary key clustered ([MODELID]))
  --declare @status int;
  --set @status=[CLR_DEV].[dbo].[fn_trace_enter]('10000000-0000-0000-0000-000000000000','[dbo].[FC_ACCESS_REPORT_TAB3]',null,null)

  declare @FR_ARC int
  set @FR_ARC = [dbo].[DEF_CLASS_ARC](1000111,'fc_report')

  if [dbo].[DEF_USERINGROUP7](@aUserID,'HRE')=1 --все отчеты, для пользователей в группе "Human Reports Editor group*/ --KB3821
  begin
    --set @status=[CLR_DEV].[dbo].[fn_trace_enter]('10000000-0000-0000-0000-000000000000','[dbo].[FC_ACCESS_REPORT_TAB3]:Block01',null,null)
    insert into @res
      select [ID]
      from [dbo].[FC_REPORT] with(nolock)
    --set @status=[CLR_DEV].[dbo].[fn_trace_leave](null)
  end else
  if [dbo].[DEF_USERINGROUP7](@aUserID,'FARALL')=1 --все отчеты, для пользователей, у которых фильтры определены во Views
  begin
    --set @status=[CLR_DEV].[dbo].[fn_trace_enter]('10000000-0000-0000-0000-000000000000','[dbo].[FC_ACCESS_REPORT_TAB3]:Block02',null,null)
    insert into @res
      select [ID]
      from [dbo].[FC_REPORT] with(nolock)
    --set @status=[CLR_DEV].[dbo].[fn_trace_leave](null)
  end else
  begin
    /* 1 если есть права на анализ или на утверждение - то вывести все по своим моделям*/
    if  [dbo].[DEF_F_ACCESS](@FR_ARC,null,1000131/*analized*/,@aDate,@aUserID,0) = 1
     or [dbo].[DEF_F_ACCESS](@FR_ARC,null,1000132/*approve */,@aDate,@aUserID,0) = 1
    begin
      --set @status=[CLR_DEV].[dbo].[fn_trace_enter]('10000000-0000-0000-0000-000000000000','[dbo].[FC_ACCESS_REPORT_TAB3]:Block03',null,null)
      insert into @res([ID])
        select distinct
          [b].[ID]
        from [dbo].[FC_ACCESS_MODELS](@aUserID,6,@aDate) [a]
          inner join [dbo].[FC_REPORT] [b] with(nolock) on [b].[MODELID]=[a].[ID]
        where [b].[EXTPARENTID] is null
      --set @status=[CLR_DEV].[dbo].[fn_trace_leave](null)

      if [dbo].[DEF_USERINGROUP4](@aUserID,'ChildFR',@aDate) = 1
      begin
        --set @status=[CLR_DEV].[dbo].[fn_trace_enter]('10000000-0000-0000-0000-000000000000','[dbo].[FC_ACCESS_REPORT_TAB3]:Block04,Block05',null,null)
        /* члены группы ChildFR видят все дочерние FR */
        insert into @ChildsT([CHILDID])
          select distinct
            [b].[FC_REPORT_CHILDID]
          from @res [a]
           inner join [dbo].[SRV_CACHE_FC_GETCHILD_FARS] [b] with(nolock) on [b].[FC_REPORT_PARENTID]=[a].[ID]

        merge @res [a]
        using
          (
          select
            [a].[CHILDID] [ID]
          from @ChildsT [a]
          ) [b] on [a].[ID]=[b].[ID]
        when not matched then
          insert ([ID]) values ([b].[ID]);
        --set @status=[CLR_DEV].[dbo].[fn_trace_leave](null)
      end
      else
      begin
        /*видеть дочерние по своим */
        --set @status=[CLR_DEV].[dbo].[fn_trace_enter]('10000000-0000-0000-0000-000000000000','[dbo].[FC_ACCESS_REPORT_TAB3]:Block06',null,null)
        insert into @ChildsT
          select distinct
            [A].[ID]
          from [dbo].[FC_REPORT] [A] with(nolock)
            inner join @res [b] on [b].[ID]=[A].[PARENTID]
          where [A].[EXTPARENTID] is null
        merge @res [a]
        using
          (
          select
            [a].[CHILDID] [ID]
          from @ChildsT [a]
          ) [b] on [a].[ID]=[b].[ID]
        when not matched then
          insert ([ID]) values ([b].[ID]);
        --set @status=[CLR_DEV].[dbo].[fn_trace_leave](null)
      end
    end
    else if [dbo].[DEF_F_ACCESS](@FR_ARC,null,1000166/*view incoming*/,@aDate,@aUserID,0) = 1
    begin
      --set @status=[CLR_DEV].[dbo].[fn_trace_enter]('10000000-0000-0000-0000-000000000000','[dbo].[FC_ACCESS_REPORT_TAB3]:Block07',null,null)
      insert into @res([ID])
        select distinct
          [b].[ID]
        from [dbo].[FC_ACCESS_MODELS](@aUserID,6,@aDate) [a]
          inner join [dbo].[FC_REPORT] [b] with(nolock) on [b].[MODELID]=[a].[ID]
        where [b].[EXTPARENTID] is null
      --set @status=[CLR_DEV].[dbo].[fn_trace_leave](null)
       /*но без дочерних*/

      if @aUserID = 3180 /*нет прав анализа, но надо "видеть" */
      begin
        --set @status=[CLR_DEV].[dbo].[fn_trace_enter]('10000000-0000-0000-0000-000000000000','[dbo].[FC_ACCESS_REPORT_TAB3]:Block08',null,null)
        delete from @ChildsT
        insert into @ChildsT
          select distinct
            [A].[ID]
          from [dbo].[FC_REPORT] [A] with(nolock)
          where [A].[PARENTID] in (select [ID] from @res)
            and [A].[EXTPARENTID] is null
        merge @res [a]
        using
          (
          select [a].[CHILDID] [ID]
          from @ChildsT [a]
          ) [b] on [a].[ID]=[b].[ID]
        when not matched then
          insert ([ID]) values ([b].[ID]);
        --set @status=[CLR_DEV].[dbo].[fn_trace_leave](null)
       end
    end
    else if [dbo].[DEF_USERINGROUP4](@aUserID,'MNGD',@aDate) = 1  /*KB3529*/
    begin
      --set @status=[CLR_DEV].[dbo].[fn_trace_enter]('10000000-0000-0000-0000-000000000000','[dbo].[FC_ACCESS_REPORT_TAB3]:Block09',null,null)
      --set @status=[CLR_DEV].[dbo].[fn_trace_enter]('10000000-0000-0000-0000-000000000000','[dbo].[FC_ACCESS_REPORT_TAB3]:Block09:01',null,null)
      delete from @DepartmentsT
      insert into @DepartmentsT
        select distinct [a].[ID]
        from [dbo].[COM_ACCESS_DEPARTMENTS](@aUserID,1,@aDate) [a]
      --set @status=[CLR_DEV].[dbo].[fn_trace_leave](null)
      --set @status=[CLR_DEV].[dbo].[fn_trace_enter]('10000000-0000-0000-0000-000000000000','[dbo].[FC_ACCESS_REPORT_TAB3]:Block09:02',null,null)
      insert into @res([ID])
        select [A].[ID]
        from [dbo].[FC_REPORT] [A] with(nolock)
          inner join [dbo].[PR_MODELS] [B] with(nolock) on [B].[ID] = [A].[MODELID]
        where [B].[DEPID] in (select [DEPID] from @DepartmentsT)
      --set @status=[CLR_DEV].[dbo].[fn_trace_leave](null)
      --set @status=[CLR_DEV].[dbo].[fn_trace_leave](null)
    end

    /* 2 если есть права на ввод*/
    if [dbo].[DEF_F_ACCESS](@FR_ARC,null,6/*create*/,@aDate,@aUserID,0) = 1
    begin
      /* 2.1 если есть права на просмотр вывести все, созданные в своем отделе (либо дочерних) */
      if [dbo].[DEF_F_ACCESS](@FR_ARC,null,3/*view*/,@aDate,@aUserID,0) = 1
      begin
        --set @status=[CLR_DEV].[dbo].[fn_trace_enter]('10000000-0000-0000-0000-000000000000','[dbo].[FC_ACCESS_REPORT_TAB3]:Block10,Block11',null,null)
        merge @res [a]
        using
          (
          select distinct [A].[ID]
          from [dbo].[COM_ACCESS_DEPARTMENTS](@aUserID,6,@aDate) [b]
            inner join [dbo].[FC_REPORT] [A] with(nolock) on [A].[FROMDEPID]=[b].[ID]
          where [A].[EXTPARENTID] is null
          ) [b] on [b].[ID]=[a].[ID]
        when not matched then
          insert ([ID]) values ([b].[ID]);
        --set @status=[CLR_DEV].[dbo].[fn_trace_leave](null)
      end
      else
      /* 2.2 иначе только свои, но тоже созданные в своем отделе (либо дочерних) */
      begin
        --set @status=[CLR_DEV].[dbo].[fn_trace_enter]('10000000-0000-0000-0000-000000000000','[dbo].[FC_ACCESS_REPORT_TAB3]:Block12',null,null)
        delete from @DepartmentsT
        insert into @DepartmentsT
          select distinct [a].[ID]
          from [dbo].[COM_ACCESS_DEPARTMENTS](@aUserID,3,@aDate) [a]
        --set @status=[CLR_DEV].[dbo].[fn_trace_leave](null)
        --set @status=[CLR_DEV].[dbo].[fn_trace_enter]('10000000-0000-0000-0000-000000000000','[dbo].[FC_ACCESS_REPORT_TAB3]:Block13',null,null)
        merge @res [a]
        using
          (
          select [A].[ID]
          from [dbo].[FC_REPORT] [A] with(nolock)
          where [A].[FROMDEPID] in (select [DEPID] from @DepartmentsT)
            and [A].[S_CR] = @aUserID
            and [A].[EXTPARENTID] is null
          ) [b] on [a].[ID]=[b].[ID]
        when not matched then
          insert ([ID]) values ([b].[ID]);
        --set @status=[CLR_DEV].[dbo].[fn_trace_leave](null)
       end
    end

    if [dbo].[DEF_USERINGROUP7](@aUserID,'R&D_PL') = 1
    begin
      --set @status=[CLR_DEV].[dbo].[fn_trace_enter]('10000000-0000-0000-0000-000000000000','[dbo].[FC_ACCESS_REPORT_TAB3]:Block14',null,null)
      merge @res [a]
      using
        (
        select distinct [A].[ID]
        from [dbo].[FC_REPORT] [A] with(nolock)
          inner join [dbo].[PR_MODELS] [B] with(nolock) on [B].[ID] = [A].[MODELID]
        where [B].[DEPID] = 170 /*PLA*/
          and [A].[EXTPARENTID] is null
        ) [b] on [a].[ID]=[b].[ID]
      when not matched then
        insert ([ID]) values ([b].[ID]);
      --set @status=[CLR_DEV].[dbo].[fn_trace_leave](null)
    end
    if @aUserID = 744 /*smaryashin*/
    begin
      --set @status=[CLR_DEV].[dbo].[fn_trace_enter]('10000000-0000-0000-0000-000000000000','[dbo].[FC_ACCESS_REPORT_TAB3]:Block15',null,null)
      merge @res [a]
      using
        (
        select distinct [A].[ID]
        from [dbo].[FC_REPORT] [A] with(nolock)
          inner join [dbo].[PR_MODELS] [B] with(nolock) on [B].[ID] = [A].[MODELID]
        where [B].[TYPEID] = 126 /*Fibers*/
          and [A].[EXTPARENTID] is null
        ) [b] on [a].[ID]=[b].[ID]
      when not matched then
        insert ([ID]) values ([b].[ID]);
      --set @status=[CLR_DEV].[dbo].[fn_trace_leave](null)
    end
  end
  --#region [TRACE]
  /*declare @OutputCount int = null
  select
    @OutputCount=count(*)
  from @res [a]
  set @status=[CLR_DEV].[dbo].[fn_trace_leave](@OutputCount)*/
  --#endregion
  return
end