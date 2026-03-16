--KB5513:2025-07-21: Refactoring.
CREATE function [dbo].[PR_ACCESS_SHARED_OPERGROUPS] (@UserID int,@Mode int,@Date datetime)
returns @res table ([ID] int primary key clustered)
as
begin
  /*
  @aMode : 0 - супервизор, видит все операции
           1 - оператор, видит только доступные операции
  */
  if @Mode = 0
  begin
    insert into @res ([ID])
      select distinct
        [soprG].[OPERGRID]
      from [dbo].[PR_SHARED_OPER_GR_EMP] [soprE] with(nolock)
        left join [dbo].[PR_SHARED_OPER_GR] [soprG] with(nolock) on [soprG].[ID]=[soprE].[VNESHID]
      where [soprG].[TODEPID] in (select [ID] from [dbo].[COM_ACCESS_DEPARTMENTS](@UserID,3,getdate()))
  end else
  if @Mode = 1
  begin
    insert into @res ([ID])
      select distinct
        [soprG].[OPERGRID]
      from [dbo].[PR_SHARED_OPER_GR_EMP] [soprE] with(nolock)
        left join [dbo].[PR_SHARED_OPER_GR] [soprG] with(nolock) on [soprG].[ID]=[soprE].[VNESHID]
      where [soprE].[EMPLID] = (select [U].[EMPLOYEEID] from [DEF_USERS] [U] with(nolock) where [U].[ID] = @UserID)
  end

  return
end