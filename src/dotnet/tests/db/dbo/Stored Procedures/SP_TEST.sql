-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[SP_TEST]
AS
BEGIN
	SET NOCOUNT ON;

  RAISERROR (15600, -1, -1, '[dbo].[SP_TEST]');

  select [b].*,[a].*
  from [dbo].[COM_EMPLOYEE] [a]
    inner join (
      select *
      from
        (
        select *,isnull([a].[ADDRESS],1000) [NADDRESS]
        from [dbo].[COM_DEPARTMENTS] [a]
        ) [a]
      where [a].[ID]>10
      ) [b] on [b].[ID]=[a].[ID]
  where [a].ID in (select [ID] from [COM_ACCCRREQ] where [ID]=[b].[ID])
    and (exists(select * from [CAPT_EYE_FI_CARDS]))

  update [a] set
     [ARC]=0
    ,[DAYSTATUS]=''
  from [dbo].[COM_CALENDAR] [a]
    inner join [PR_OPERATION] [b] on [b].[ID]=[a].[ID] and [a].[ID]=-1
  where [b].[COMPLETED_DT] is not null

  update [dbo].[PR_OPER_RULES] set
     [ARC]=0
    ,[ERRTEXT]=''
  where [ID]<0

  insert into [dbo].[PR_OPERATION]([ARC])
  values(0)

  insert into [dbo].[PR_OPERATION]([ARC])
    select [ID]
    from [dbo].[PR_OPERATION]

  ;with [X]
  as
    (
    select * from [dbo].[COM_DEPARTMENTS]
    ),
  [Y] as
    (
    select *
    from [dbo].[COM_EMPLOYEE] [a]
    )
  insert into [dbo].[EQ_EQUIPMENT]([PDATE],[PONUMBER])
    select [a].[S_CDT],[a].[ADDRESS]
    from [X] [a]
      inner join (select * from [Y] [a] where [a].[ID]>10) [b] on [b].[ID]=[a].[ID]
    where [a].ID in (select [ID] from [COM_ACCCRREQ])
      and (exists(select * from [CAPT_EYE_FI_CARDS]))

  ;with [X]
  as
  (
  select * from [dbo].[COM_DEPARTMENTS]
  ),
  [Y] as
  (
  select *
  from [dbo].[COM_EMPLOYEE] [a]
  )
  select *
  from [X] [a]
    inner join (select * from [Y] [a] where [a].[ID]>10) [b] on [b].[ID]=[a].[ID]
  where [a].ID in (select [ID] from [COM_ACCCRREQ])
    and (exists(select * from [CAPT_EYE_FI_CARDS]))
END