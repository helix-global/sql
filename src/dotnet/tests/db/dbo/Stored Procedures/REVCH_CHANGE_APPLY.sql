--2025-03-17:KB5305: Added check for employee role.
--2024-06-28:KB4765: Efimov
CREATE procedure [dbo].[REVCH_CHANGE_APPLY] @DocumentID int, @UserID int
as
set nocount on

declare @NewMapID int
declare @revCou int
declare @mtid int

select
   @NewMapID = [a].[MAPID]
  ,@revCou = (select count(*) from [dbo].[REVCH_CHANGE_REV] [b] where [b].[VNESHID] = [a].[ID])
  ,@mtid = [a].[MTID]
from [dbo].[REVCH_CHANGE] [a]
where [a].[ID] = @DocumentID

if @revCou = 0
begin
  raiserror('Affected revisions table is empty. Cannot apply the changing.',16,0)
  set nocount off
  return
end

if exists (select
             [c].[ID]
           from [dbo].[REVCH_CHANGE_REV] [a]
             left join [dbo].[PR_REVISION] [b] on [b].[ID] = [a].[REVID]
             left join [dbo].[PR_MODELS]   [c] on [c].[ID] = [b].[MODELID]
           where [a].[VNESHID] = @DocumentID
             and [c].[TYPEID] <> @mtid)
begin
  raiserror('Affected revisions table contains revisions from different model type. Cannot apply the changing.',16,0)
  set nocount off
  return
end

if exists (select [b].[ID]
           from [dbo].[REVCH_CHANGE_PRMS] [a]
             left join [dbo].[PR_MODELTYPE_PARAMS] [b] on [b].[ID] = [a].[PARAMID]
           where [a].[VNESHID] = @DocumentID
           and [b].[TYPEID] <> @mtid)
begin
  raiserror('Parameters table contains parameters from different model type. Cannot apply the changing.',16,0)
  set nocount off
  return
end

if exists (select [a].[ID]
           from [dbo].[REVCH_CHANGE_PDMU] [a]
           where [a].[VNESHID] = @DocumentID
             and [a].[PACT] = 20  /*modify PDMU */
             and [a].[OLD_MID] is null)
begin
  raiserror('Rows with "Modify" action in "Predefined Materials To Change" should contains "Old Code" value. Cannot apply the changing.',16,0)
  set nocount off
  return
end

if exists (select [a].[ID]
           from [dbo].[REVCH_CHANGE_PDMU] [a]
           where [a].[VNESHID] = @DocumentID
             and [a].[PACT] = 10  /*add PDMU */
             and [a].[MID] is null)
begin
  raiserror('Rows with "Add" action in "Predefined Materials To Change" should contains "Code" value. Cannot apply the changing.',16,0)
  set nocount off
  return
end

if exists (select [a].[ID]
           from [dbo].[REVCH_CHANGE_PDMU] [a]
           where [a].[VNESHID] = @DocumentID
             and [a].[PACT] in (10 /*add PDMU *//*,20 KB3872*//*modify*/)
             and (/*[a].[MID] is null or*/ [a].[QUANTITY] is null))
begin
  raiserror('Rows with "Add" action in "Predefined Materials To Change" should contains "Quantity" values. Cannot apply the changing.',16,0)
  set nocount off
  return
end

if exists (select [b].[ID]
           from [dbo].[REVCH_CHANGE_BOM2] [a]
             left join [PR_MODELTYPE_BOM] [b] on [b].[ID] = [a].[BOMID]
           where [a].[VNESHID] = @DocumentID
             and [b].[MTID] <> @mtid)
begin
  raiserror('BOM item models table contains BOM items from different model type. Cannot apply the changing.',16,0)
  set nocount off
  return
end

if @NewMapID is null
  and not exists (select [b].[ID] from [dbo].[REVCH_CHANGE_BOM2] [b] where [b].[VNESHID] = @DocumentID)
  and not exists (select [b].[ID] from [dbo].[REVCH_CHANGE_PRMS] [b] where [b].[VNESHID] = @DocumentID)
  and not exists (select [b].[ID] from [dbo].[REVCH_CHANGE_PDMU] [b] where [b].[VNESHID] = @DocumentID)
  and not exists (select [b].[ID] from [dbo].[REVCH_CHANGE_COMP] [b] where [b].[VNESHID] = @DocumentID)
  and not exists (select [b].[ID] from [dbo].[REVCH_CHANGE_SW]   [b] where [b].[VNESHID] = @DocumentID) /* KB4899 (KB4765) */
begin
  raiserror('The document does not contains any changes. Cannot apply the document.',16,0)
  set nocount off
  return
end

declare @hasChanges int = 0

if ([dbo].[DEF_USERINGROUP4](@UserID,'DH&VICE',getdate()) = 0) and
   --KB5305:
   not exists (select [u].[ID]
               from [dbo].[DEF_USERS] [u] with(nolock)
                 inner join [dbo].[COM_EMPLOYEE] [e] with(nolock) on [e].[ID]=[u].[EMPLOYEEID]
               where [e].[ROLEINDEP] in (10,100)
                 and [u].[ID]=@UserID)
begin
  update [PR_REVISION] set
    [S_S] = 1
  where [ID] in (select [b].[REVID]
                 from [dbo].[REVCH_CHANGE_REV] [b]
                 where [b].[VNESHID] = @DocumentID)
    and [S_S] = 1000017
  if @@rowcount > 0
    print '#IRevisions should be approved after changings by department head or vice.'
end

if (@NewMapID is not null)
begin
  update [PR_REVISION] set
    [MAPID] = @NewMapID
  where [ID] in (select [b].[REVID] from [dbo].[REVCH_CHANGE_REV] [b] where [b].[VNESHID] = @DocumentID)

  if exists (select [b].[REVID] from [dbo].[REVCH_CHANGE_REV] [b] where [b].[VNESHID] = @DocumentID)
  begin
    set @hasChanges = 1
  end
end

if exists (select [b].[ID] from [dbo].[REVCH_CHANGE_BOM2] [b] where [b].[VNESHID] = @DocumentID)
begin
  declare @existBOMrevisions table (ID int)

  insert into @existBOMrevisions ([ID])
    select [a].[REVID]
    from [dbo].[PR_REV_BOM2] [a]
    where [a].[REVID] in (select [b].[REVID] from [dbo].[REVCH_CHANGE_REV] [b] where [b].[VNESHID] = @DocumentID)
      and [a].[BOMID] in (select distinct [c].[BOMID] from [dbo].[REVCH_CHANGE_BOM2] [c] where [c].[VNESHID] = @DocumentID and [c].[PACT] in (3))

  delete from [dbo].[PR_REV_BOM2]
  where [REVID] in (select [b].[REVID] from [dbo].[REVCH_CHANGE_REV] [b] where [b].[VNESHID] = @DocumentID)
    and [BOMID] in (select distinct [c].[BOMID] from [dbo].[REVCH_CHANGE_BOM2] [c] where [c].[VNESHID] = @DocumentID and [c].[PACT] in (1,3))

  delete from [dbo].[PR_REV_BOM2]
  where [REVID] in (select [b].[REVID] from [dbo].[REVCH_CHANGE_REV] [b] where [b].[VNESHID] = @DocumentID)
    and exists (select [d].[ID] from [dbo].[REVCH_CHANGE_BOM2] [d]
                 where [d].[VNESHID] = @DocumentID 
                   and [d].[PACT] in (100) 
                   and [d].[BOMID] = [PR_REV_BOM2].[BOMID]
                   and [d].[PARTMODELID] = [PR_REV_BOM2].[PARTMODELID])

  insert into [PR_REV_BOM2] ([GID],[REVID],[S_CR],[S_CDT],[BOMID],[PARTMODELID],[ONLYOPTION],[ONLYOPTION2],[ONLYOPTION3],[QTY],[TYPICAL2NAV])
    select newid(),[a].[REVID],@UserID,getdate(),[b].[BOMID],[b].[PARTMODELID],[b].[ONLYOPTION],[b].[ONLYOPTION2],[b].[ONLYOPTION3],[b].[QTY],[b].[TYPICAL2NAV]
    from [dbo].[REVCH_CHANGE_BOM2] [b]
      left join [dbo].[REVCH_CHANGE_REV] [a] on [a].[VNESHID] = [b].[VNESHID]
    where [b].[VNESHID] = @DocumentID
      and [b].[PACT] in (1,2)

  insert into [dbo].[PR_REV_BOM2] ([GID],[REVID],[S_CR],[S_CDT],[BOMID],[PARTMODELID],[ONLYOPTION],[ONLYOPTION2],[ONLYOPTION3],[QTY],[TYPICAL2NAV])
    select newid(),[a].[REVID],@UserID,getdate(),[b].[BOMID],[b].[PARTMODELID],[b].[ONLYOPTION],[b].[ONLYOPTION2],[b].[ONLYOPTION3],[b].[QTY],[b].[TYPICAL2NAV]
    from [dbo].[REVCH_CHANGE_BOM2] [b]
      left join [dbo].[REVCH_CHANGE_REV] [a] on [a].[VNESHID] = [b].[VNESHID]
    where [b].[VNESHID] = @DocumentID
      and [b].[PACT] in (3)
      and [a].[REVID] in (select [ID] from @existBOMrevisions)

  set @hasChanges = 1
end

if exists (select [b].[ID] from [dbo].[REVCH_CHANGE_PRMS] [b] where [b].[VNESHID] = @DocumentID)
begin
  delete from [dbo].[PR_REV_PARAMS]
  where [REVISIONID] in (select [b].[REVID] from [dbo].[REVCH_CHANGE_REV] [b] where [b].[VNESHID] = @DocumentID)
    and [PARAMID] in (select distinct [c].[PARAMID] from [dbo].[REVCH_CHANGE_PRMS] [c] where [c].[VNESHID] = @DocumentID and [c].[PACT] in (1,100))

  insert into [dbo].[PR_REV_PARAMS] ([GID],[REVISIONID],[S_CR],[S_CDT],[PARAMID],[ONLYOPTION],[PVALUE])
    select newid(),[a].[REVID],@UserID,getdate(),[b].[PARAMID],[b].[ONLYOPTION],[b].[PVALUE]
    from [dbo].[REVCH_CHANGE_PRMS] [b]
      left join [dbo].[REVCH_CHANGE_REV] [a] on [a].[VNESHID] = [b].[VNESHID]
    where [b].[VNESHID] = @DocumentID
      and [b].[PACT] in (1,2)

  set @hasChanges = 1
end

if exists (select [b].[ID] from [dbo].[REVCH_CHANGE_COMP] [b] where [b].[VNESHID] = @DocumentID)
begin
    /*delete*/
  delete from [PR_REV_COMPM]
  where [REVID] in (select [b].[REVID] from [dbo].[REVCH_CHANGE_REV] [b] with(nolock) where [b].[VNESHID] = @DocumentID)
    and exists (select [g].[ID]
                from [dbo].[REVCH_CHANGE_COMP] [g] with(nolock)
                where [g].[VNESHID] = @DocumentID 
                  and [g].[PACT] in (100)
                  and [g].[MODELID] = [PR_REV_COMPM].[MODELID]
                  and [g].[COMPMODELID] = [PR_REV_COMPM].[COMPMODELID])

    /*add*/
  insert into [dbo].[PR_REV_COMPM] ([GID],[REVID],[S_CR],[S_CDT],[MODELID],[COMPMODELID])
    select newid(),[a].[REVID],@UserID,getdate(),[b].[MODELID],[b].[COMPMODELID]
    from [dbo].[REVCH_CHANGE_COMP] [b] with(nolock)
      left join [dbo].[REVCH_CHANGE_REV] [a] with(nolock) on [a].[VNESHID] = [b].[VNESHID]
    where [b].[VNESHID] = @DocumentID
      and [b].[PACT] in (10)
end

if exists (select [b].[ID] from [dbo].[REVCH_CHANGE_PDMU] [b] where [b].[VNESHID] = @DocumentID)
begin
  /*delete*/
  delete from [dbo].[PR_REV_PDMU]
  where [REVID] in (select [b].[REVID] from [dbo].[REVCH_CHANGE_REV] [b] with(nolock) where [b].[VNESHID] = @DocumentID)
    and exists (select [g].[ID]
                from [dbo].[REVCH_CHANGE_PDMU] [g] with(nolock)
                where [g].[VNESHID] = @DocumentID 
                  and [g].[PACT] in (100)
                  and [g].[OPERID] = [PR_REV_PDMU].[OPERID]
                 and ([g].[OLD_MID] = [PR_REV_PDMU].[MID] or [g].[OLD_MID] is null))

  /*add*/
  insert into [dbo].[PR_REV_PDMU] ([GID],[REVID],[S_CR],[S_CDT],[OPERID],[QUANTITY],[MID],[NOADDQUANTITY],[USEINREPEATED],[ONLYOPTION],[USEOPTQTY],[TYPICAL2NAV])
    select newid(),[a].[REVID],@UserID,getdate(),[b].[OPERID],[b].[QUANTITY],[b].[MID],[b].[NOADDQUANTITY],[b].[USEINREPEATED],[b].[ONLYOPTION],[b].[USEOPTQTY],[b].[TYPICAL2NAV]
    from [dbo].[REVCH_CHANGE_PDMU] [b] with(nolock)
      left join [dbo].[REVCH_CHANGE_REV] [a] with(nolock) on [a].[VNESHID] = [b].[VNESHID]
    where [b].[VNESHID] = @DocumentID
      and [b].[PACT] in (10)

  /*modify*/
  if exists (select [b].[ID] from [REVCH_CHANGE_PDMU] [b] where [b].[VNESHID] = @DocumentID and [b].[PACT] = 20)
  begin
    declare @ff_id int
    declare @ff_operid int
    declare @ff_old_mid int
    declare @nn_mid int
    declare @nn_noaddq int
    declare @nn_useinrep int
    declare @nn_onlyoption int
    declare @nn_useoptqty int
    declare @nn_typical2nav int
    declare @nn_qty decimal(18,6)

    declare [cursor] cursor local read_only for
      select [ID],[OPERID],[OLD_MID],[MID],[NOADDQUANTITY],[USEINREPEATED],[ONLYOPTION],[USEOPTQTY],[TYPICAL2NAV],[QUANTITY]
      from [dbo].[REVCH_CHANGE_PDMU] [b]
      where [b].[VNESHID] = @DocumentID 
        and [b].[PACT] = 20

    open [cursor]
    while 1=1
    begin
      fetch next from [cursor] into @ff_id,@ff_operid,@ff_old_mid,@nn_mid,@nn_noaddq,@nn_useinrep,@nn_onlyoption,@nn_useoptqty,@nn_typical2nav,@nn_qty
      if @@FETCH_STATUS<>0 break;

      if @ff_old_mid is null
        raiserror('Rows with "Modify" action in "Predefined Materials To Change" should contains "Old Code" value. ',16,0)

      update [dbo].[PR_REV_PDMU] set
         [S_MR] = @UserID
        ,[S_MDT] = getdate()
        ,[MID] = isnull(@nn_mid,[MID])
        ,[NOADDQUANTITY] = @nn_noaddq
        ,[USEINREPEATED] = @nn_useinrep
        ,[ONLYOPTION] = @nn_onlyoption
        ,[USEOPTQTY] = @nn_useoptqty
        ,[TYPICAL2NAV] = @nn_typical2nav
        ,[QUANTITY] = isnull(@nn_qty,[QUANTITY])  /*KB3872*/
      where [REVID] in (select [b].[REVID] from [dbo].[REVCH_CHANGE_REV] [b] with(nolock) where [b].[VNESHID] = @DocumentID)
        and [PR_REV_PDMU].[OPERID] = @ff_operid
        and [PR_REV_PDMU].[MID] = @ff_old_mid
    end
    close [cursor];
    deallocate [cursor];
  end

  set @hasChanges = 1
end

/*  проверить PR_REV_BOM2 по затронутым ревизиям на предмет корректности TYPICAL2NAV */
if exists (select [b].[ID] from [dbo].[REVCH_CHANGE_BOM2] [b] where [b].[VNESHID] = @DocumentID)
begin
  declare @errLineID int = null
  select top 1 @errLineID = [a].[ID]
  from [dbo].[PR_REV_BOM2] [a] with(nolock)
    left join [dbo].[PR_REVISION] [b] with(nolock) on [b].[ID] = [a].[REVID]
  where [a].[REVID] in (select [b].[REVID] from [dbo].[REVCH_CHANGE_REV] [b] with(nolock) where [b].[VNESHID] = @DocumentID)
    and isnull([a].[TYPICAL2NAV],0) = 0
    and isnull([b].[SYNC2NAV],0) > 0
    and exists(select [b].[ID]
               from [dbo].[PR_REV_BOM2] [b] with(nolock)
               where [b].[REVID] = [a].[REVID]
                 and [b].[BOMID] = [a].[BOMID]
                 and isnull([b].[TYPICAL2NAV],0) = 0
                 and [b].[ID] <> [a].[ID])

  if @errLineID is not null
  begin
    declare @errRevName nvarchar(200)
    declare @errRevModelName nvarchar(300)
    declare @errBOMItemName nvarchar(200)

    select
       @errBOMItemName = [b].[NAME]
      ,@errRevModelName = [m].[NAME]
      ,@errRevName = [r].[NAME]
    from [dbo].[PR_REV_BOM2] [a] with(nolock)
      left join [dbo].[PR_MODELTYPE_BOM] [b] with(nolock) on [b].[ID] = [a].[BOMID]
      left join [dbo].[PR_REVISION]      [r] with(nolock) on [r].[ID] = [a].[REVID]
      left join [dbo].[PR_MODELS]        [m] with(nolock) on [m].[ID] = [r].[MODELID]
    where [a].[ID] = @errLineID

    declare @errMesss nvarchar(max)
    set @errMesss = '#EError in "Alternative Position" setting for BOM item "'+isnull(@errBOMItemName,'NA')+'" in revision "'+isnull(@errRevName,'NA')+'" of model "'+isnull(@errRevModelName,'NA')+'". Please enable "Alternative Position" for the BOM item if several models are possible to install.'

    raiserror(@errMesss,16,1)
    set nocount off
    return
  end
end

/* KB4765 EMF 28.06.2028  => */

/*delete*/
if exists (select [b].[ID] from [dbo].[REVCH_CHANGE_SW] [b] where [b].[VNESHID] = @DocumentID and [b].[PACT] = 100)
begin
  delete from [dbo].[PR_REV_SW]
  where [REVID] in (select [b].[REVID] from [dbo].[REVCH_CHANGE_REV] [b] with(nolock) where [b].[VNESHID] = @DocumentID)
    and exists (select [SW].[ID]
                from [dbo].[REVCH_CHANGE_SW] [SW] with(nolock)
                where [SW].[VNESHID] = @DocumentID  -- in looking revision
                  and [SW].[PACT] in (100)          -- with need to delete
                  and [SW].[SWID_OLD] = [PR_REV_SW].[SWID]
                  and ([SW].[SWTOOLID_OLD] = [PR_REV_SW].[SWTOOLID] or [SW].[SWTOOLID_OLD] is null)
                  and ([SW].[SWVERSIONID_OLD] = [PR_REV_SW].[SWVERSIONID] or [SW].[SWVERSIONID_OLD] is null)
                  and ([SW].[SWMODE_OLD] = [PR_REV_SW].[SWMODE] or [SW].[SWMODE_OLD] is null)
                  and ([SW].[ONLYOPTION_OLD] = [PR_REV_SW].[ONLYOPTION] or [SW].[ONLYOPTION_OLD] is null)
                  and ([SW].[ONLYOPTION2_OLD] = [PR_REV_SW].[ONLYOPTION2] or [SW].[ONLYOPTION2_OLD] is null)
                  and ([SW].[ONLYOPTION3_OLD] = [PR_REV_SW].[ONLYOPTION3] or [SW].[ONLYOPTION3_OLD] is null))
  set @hasChanges = 1
end

/* insert */
if exists (select [b].[ID] from [dbo].[REVCH_CHANGE_SW] [b] where [b].[VNESHID] = @DocumentID and [b].[PACT] = 10)
begin
  insert into [dbo].[PR_REV_SW] ([GID],[S_CR],[S_CDT],[REVID],[SWID],[SWMODE],[SWVERSIONID],[ONLYOPTION],[SWTOOLID],[ONLYOPTION2],[ONLYOPTION3])
    select newid() as [GID],@UserID as [S_CR],getdate() as [S_CDT],[a].[REVID],[NEW_SW].[SWID],[SWMODE],[SWVERSIONID],[ONLYOPTION], [SWTOOLID],[ONLYOPTION2],[ONLYOPTION3]
    from [dbo].[REVCH_CHANGE_SW] [NEW_SW] with(nolock)
      left join [dbo].[REVCH_CHANGE_REV] [a] on [a].[VNESHID] = [NEW_SW].[VNESHID]
    where [NEW_SW].[VNESHID] = @DocumentID
      and [NEW_SW].[PACT] in (10)

  set @hasChanges = 1
end

/* update */
if exists (select [b].[ID] from [dbo].[REVCH_CHANGE_SW] [b] where [b].[VNESHID] = @DocumentID and [b].[PACT] = 20)
begin
  update [a] set
     [a].[SWID] = [b].[SWID]
    ,[a].[SWMODE] = [b].[SWMODE]
    ,[a].[SWVERSIONID] = [b].[SWVERSIONID]
    ,[a].[ONLYOPTION] = [b].[ONLYOPTION]
    ,[a].[SWTOOLID] = [b].[SWTOOLID]
    ,[a].[ONLYOPTION2] = [b].[ONLYOPTION2]
    ,[a].[ONLYOPTION3] = [b].[ONLYOPTION3]
    ,[a].[S_MR] = @UserID
    ,[a].[S_MDT] = getdate()
  from [dbo].[PR_REV_SW] [a]
    inner join [dbo].[REVCH_CHANGE_SW] [b] on [b].[VNESHID] = @DocumentID  -- in looking revision
           and [a].[REVID] in (select [b].[REVID] from [dbo].[REVCH_CHANGE_REV] [b] with(nolock) where [b].[VNESHID] = @DocumentID) 
           and [b].[PACT] = 20       -- with need to update
           and [b].[SWID_OLD] = [a].[SWID]
           and ([b].[SWTOOLID_OLD] = [a].[SWTOOLID] or [b].[SWTOOLID_OLD] is null)
           and ([b].[SWVERSIONID_OLD] = [a].[SWVERSIONID] or [b].[SWVERSIONID_OLD] is null)
           and ([b].[SWMODE_OLD] = [a].[SWMODE] or [b].[SWMODE_OLD] is null)
           and ([b].[ONLYOPTION_OLD] = [a].[ONLYOPTION] or [b].[ONLYOPTION_OLD] is null)
           and ([b].[ONLYOPTION2_OLD] = [a].[ONLYOPTION2] or [b].[ONLYOPTION2_OLD] is null)
           and ([b].[ONLYOPTION3_OLD] = [a].[ONLYOPTION3] or [b].[ONLYOPTION3_OLD] is null)

  set @hasChanges = 1
end
/* <= KB4765 EMF 28.06.2024 */

if (@hasChanges = 1)
begin
  update [dbo].[PR_REVISION] set
     [S_MR] = @UserID
    ,[S_MDT]=getdate()
  where [ID] in (select [b].[REVID] from [dbo].[REVCH_CHANGE_REV] [b] where [b].[VNESHID] = @DocumentID)
end

set nocount off