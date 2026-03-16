-- KB5383:2025-04-22: Refactoring. Added check for [dbo].[PR_MODELS_CAN_PRODUCE_MODEL].
-- KB5392:2025-05-05: Added check for [dbo].[PR_MODELS_CAN_PRODUCE_MODEL] but script made without using "merge".
-- KB5392:2025-05-06: Removed check for [dbo].[PR_MODELS_CAN_PRODUCE_MODEL] its replaced by inline computation instead.
-- KB5418:2025-05-12: Fixed visibility error. Added "and [shr].[RULETYPE]=1" condition.
CREATE function [dbo].[PR_ACCESS_MODELS] (@UserID int,@Mode int,@Date datetime)
returns @OutT table ([ID] int)
as
begin
  declare @DepAccessT table([DEPID] int primary key clustered)
  insert into @DepAccessT
    select distinct [a].[ID]
    from [dbo].[COM_ACCESS_DEPARTMENTS](@UserID,@Mode,@Date) [a]

  insert into @OutT ([ID])
    select [mdl].[ID]
    from [dbo].[PR_MODELS] [mdl] with(nolock)
    where [mdl].[DEPID] in (select [DEPID] from @DepAccessT)

  declare @UserDepID  int
  select top 1
    @UserDepID=[e].[DEPID]
  from [dbo].[DEF_USERS] [u] with(nolock)
    inner join [dbo].[COM_EMPLOYEE] [e] with(nolock) on [e].[ID]=[u].[EMPLOYEEID]
  where [u].[ID]=@UserID

  if @Mode = 4 /*devices*/
  begin
    /*09.02.2017 пришлось срочно давать права видеть фрязинские изделия отделу FCM-MM не по подразделению MMC_R, а по типу модели "Cladding mode absorber"*/
    insert into @OutT ([ID])
      select distinct [mdl].[ID]
      from [dbo].[PR_MODELS] [mdl] with(nolock)
      where [mdl].[DEPID]=@UserDepID
         or exists(select *
                   from [dbo].[PR_MODEL_SHARINGR] [shr] with(nolock)
                   where [shr].[MODELID]=[mdl].[ID]
                     and [shr].[DEPARTMENTID]=@UserDepID
                     and [shr].[RULETYPE]=1 --Production {a2l:\\Link=oid.def_enumeration.1000085}
                  )
         or [mdl].[TYPEID] in (select [mdt].[ID]
                               from [dbo].[PR_MODELTYPE] [mdt] with(nolock)
                               where [dbo].[DEF_F_ACCESS2]([mdt].[ARC],[mdt].[S_CR],1000268,@Date,@UserID,0) = 1) -- a2l:\\Link=oid.def_class_methods.1000268 {View Devices from Any Departments}
        and not exists (select [c].[ID] from @OutT [c] where [c].[ID] = [mdl].[ID])

    /* по виртуальной группе доступа "Model Type Owner" */
    insert into @OutT ([ID])
      select [mdl].[ID]
      from [dbo].[PR_MODELS] [mdl] with(nolock)
        left join [dbo].[PR_MODELTYPE]    [mdt] with(nolock) on [mdt].[ID]=[mdl].[TYPEID]
        left join [dbo].[COM_DEPARTMENTS] [dep] with(nolock) on [dep].[ID]=[mdl].[DEPID]
      where [mdl].[DEPID] <> [mdt].[DEPARTMENTID]
        and [mdt].[DEPARTMENTID] in (select [DEPID] from @DepAccessT)
        and [dbo].[DEF_FUNC_ACCESS]([dep].[ARC],1000099/*view dep devices*/,'MTOwn',@Date) = 1
        and not exists (select [c].[ID] from @OutT [c] where [c].[ID] = [mdl].[ID])
  
    /*10.10.2018 заявка 10953
    реализовать доступ к любым изделиям немецких типов моделей отдела FP, если у сотрудника имеется вкладка FP
    */
    declare @AccesstoFP int
    select
      @AccesstoFP = [dbo].[COM_DEP_ACCESS2]([dep].[ID],4,@UserID,@Date)
    from [dbo].[COM_DEPARTMENTS] [dep] with(nolock)
    where [dep].[GID] = '27332ba0-fd72-4383-8c0a-83b99f45c50f' /*FP*/

    if @AccesstoFP = 1
    begin
      declare @FPARC int
      set @FPARC = [dbo].[DEF_CLASS_ARC](1000265,'cs_fibers_readonly')

      set @AccesstoFP = 0
      set @AccesstoFP = [dbo].[DEF_F_ACCESS](@FPARC,null,2/*use*/,@Date,@UserID,0)

      if @AccesstoFP = 1
      begin
        insert into @OutT ([ID])
          select [m].[ID]
          from [dbo].[PR_MODELS] [m] with(nolock)
            left join [dbo].[PR_MODELTYPE]    [t] with(nolock) on [t].[ID]=[m].[TYPEID]
            left join [dbo].[COM_DEPARTMENTS] [c] with(nolock) on [c].[ID]=[m].[DEPID]
            left join [dbo].[COM_DEPARTMENTS] [d] with(nolock) on [d].[ID]=[t].[DEPARTMENTID]
          where [m].[DEPID] <> [t].[DEPARTMENTID]
            and [d].[GID] = '27332ba0-fd72-4383-8c0a-83b99f45c50f' /*FP*/
            and not exists (select [c].[ID] from @OutT [c] where [c].[ID] = [m].[ID])
      end
    end
  end

  -- KB5308 (part) =>
  -- leave only one uniq values (remove duplicates)
  ;WITH CTE_Duplicates AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY ID ORDER BY (SELECT NULL)) AS rn
    FROM @OutT
	)
  DELETE FROM CTE_Duplicates
  WHERE rn > 1;
  

  return 


end