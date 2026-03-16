-- KB5038:2025-01-06: Added "UserGroup=".
-- KB4848:2024-06-14: Ignore fine access for project leader and co-leader.
CREATE function [dbo].[PM_TASK_FINEACCESS](@aTaskID int, @aUserID int, @aMode int, @aDate datetime)
returns nvarchar(max)
as
begin
  declare @res nvarchar(max)
  set @res = ''

  declare @emplid int
  set @emplid = dbo.DEF_EMPLOYEE(@aUserID)

  declare @isManager int = 1
  declare @isAssignee int = 0  /*KB3201*/

  if exists (select A.ID from PM_TASK_ASSIGNEE A with (nolock) where A.VNESHID = @aTaskID and A.EMPLID = @emplid)
  begin
    set @isAssignee = 1
    set @res = 'UserGroup=Assignee'
  end

  if dbo.DEF_USERINGROUP5(@aUserID,'PM','DH&VICE','PD',null,null) <> 1 
  begin
    set @isManager = 0
    if @isAssignee = 0
       return 'FullReadOnly;NoAllActions';
  end

  if @isAssignee = 0
    set @res = @res + ';NoActionsMarked=onlyassignee';

  declare @ownerDepID int
  declare @authorID int
  declare @projleaderID int
  declare @respDepID int

  select
     @ownerDepID = A.DEPID
    ,@authorID = A.S_CR
    ,@projleaderID = B.PROJLEAD
    ,@respDepID = A.RESPDEP
  from PM_TASK A with (nolock)
    left join PM_PROJECT B with(nolock) on B.ID = A.PROJID
  where A.ID = @aTaskID

  --KB4848:Fetching leader and co-leader user identifiers
  declare @ProjLeadT table([USERID] int,[TYPE] int,unique clustered ([USERID]))
  insert into @ProjLeadT
    select distinct [u].[ID],0
    from [dbo].[PM_TASK] [t] with(nolock)
      inner join [dbo].[PM_PROJECT_COLEADERS] [c] with(nolock) on [c].[VNESHID]=[t].[PROJID]
      inner join [dbo].[DEF_USERS]            [u] with(nolock) on [u].[EMPLOYEEID]=[c].[EMPLID]
    where [t].[ID]=@aTaskID

  merge into @ProjLeadT [a]
  using
    (
    select distinct [u].[ID] [USERID]
    from [dbo].[PM_TASK] [t] with(nolock)
      inner join [dbo].[PM_PROJECT] [p] with(nolock) on [p].[ID]=[t].[PROJID]
      inner join [dbo].[DEF_USERS]  [u] with(nolock) on [u].[EMPLOYEEID]=[p].[PROJLEAD]
    where [t].[ID]=@aTaskID
    ) [b] on [b].[USERID]=[a].[USERID]
  when not matched then
    insert ([USERID],[TYPE]) values ([b].[USERID],1)
  when matched then
    update set
      [TYPE]=1
    ;

  --KB4848:If specified user is leader or co-leader than just returns "NoActionsMarked=onlyLeaderOrAuthor".
  if exists(select * from @ProjLeadT [a] where [a].[USERID]=@aUserID)
  begin
    if @isAssignee = 1
      return 'UserGroup=LeaderOrAuthor;UserGroup=Assignee'
    return 'UserGroup=LeaderOrAuthor'
  end

  if @emplid <> isnull(@projleaderID,-5465) and @authorID <> @aUserID /*KB3217*/
    set @res = @res + ';NoActionsMarked=onlyLeaderOrAuthor';

  if  @authorID <> @aUserID /*KB3950 pos.1*/
    set @res = @res + ';NoActionsMarked=onlyAuthor'
  else
    set @res = @res + ';UserGroup=Author'


  if dbo.COM_DEP_ACCESS(null,@ownerDepID,@aMode,@aUserID,@aDate) <> 1
    set @res = @res + ';NoActionsMarked=onlyowner'
  else
    set @res = @res + ';UserGroup=Owner'

  if @isManager = 0
    set @res = @res + ';ReadOnlyGroup=100';

  /*KB3950 pos.2  определяем является пользователь начальником responsible отдела*/ 
  if exists (select D.ID 
               from COM_EMPLOYEE D with(nolock) 
              where D.ID = @emplid
                and D.ROLEINDEP in (10,100)
                and D.DEPID in (select ID from dbo.COM_GETPARENT_DEPARTMENTS(@respDepID,1))
             )
   begin
      set @res = @res + ';BypassActionsMarked=Keep4RespDepHead;UserGroup=RespDepHead';
   end

  if LEN(@res) = 0
     return null

  return @res
end;