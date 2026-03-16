--KB5513:2025-07-21: Refactoring.
CREATE FUNCTION [dbo].[PR_ACCESS_SHARED_OPERATION](@UserId int,@Date datetime,@OnlyMy int)
returns @OutT table([ID] int primary key clustered)
as
begin
  /* @OnlyMy 0 - все переданные операции в отдел (для супервизоров) */
  /*         1 - только операции, где пользователь допущен (для операторов) */ 

  declare @DepT table([DEPID] int primary key clustered)
  insert into @DepT
    select distinct
      [app].[TODEPID]
    from [dbo].[PR_SHARED_OPERATION_APP] [app] with(nolock)

  delete from @DepT
  where [dbo].[COM_DEP_ACCESS](null,[DEPID],1,@UserID,@Date) <> 1

  /*строки из [PR_SHARED_OPERATION_APP] переданные на мой отдел*/
  declare @MyAppT table ([DEVICEID] int,[MAPOPERID] int,primary key clustered ([DEVICEID],[MAPOPERID]))
  insert into @MyAppT([DEVICEID],[MAPOPERID])
    select distinct
       [app].[DEVICEID]
      ,[app].[MAPOPERID]
    from [dbo].[PR_SHARED_OPERATION_APP] [app] with(nolock)
      left join [dbo].[PR_DEVICE] [dev] with(nolock) on [dev].[ID]=[app].[DEVICEID]
    where [dev].[COMPLETED_DT] is null /*разрешаем только изделия в производстве, иначе по старым записям в PR_SHARED_OPERATION_APP*/
                                       /*могут появится ремонтные операции в других отделах, когда изделие вернется в ремонт*/
      and [app].[TODEPID] in (select [DEPID] from @DepT)

  insert into @OutT
    select [opr].[ID]
    from [dbo].[PR_OPERATION] [opr] with(nolock)
      left join [dbo].[PR_OPERATIONS] [opF] with(nolock) on [opF].[ID]=[opr].[OPERTYPEID]
    where [opr].[DEVICEID]  in (select [app].[DEVICEID]  from @MyAppT [app])
      and [opr].[REVOPERID] in (select [app].[MAPOPERID] from @MyAppT [app] where [app].[DEVICEID]=[opr].[DEVICEID])
      and (@OnlyMy = 0 or [opF].[OPERGRID] in (select [soprG].[OPERGRID]
                                               from [dbo].[PR_SHARED_OPER_GR] [soprG] with(nolock)
                                                 left join [dbo].[PR_SHARED_OPER_GR_EMP] [soprE] with(nolock) on [soprE].[VNESHID]=[soprG].[ID]
                                                 left join [dbo].[DEF_USERS]             [users] with(nolock) on [users].[EMPLOYEEID]=[soprE].[EMPLID]
                                               where [users].[ID] = @UserId))
  return
end