-- =============================================
-- Author:      <Author,,Name>
-- Create date: <Create Date,,>
-- Description: <Description,,>
-- =============================================
CREATE FUNCTION [dbo].[COM_MODEL_FILTER_BY_SKILL]
(
    @skillID int
)
RETURNS @t table (ID int)
AS
begin

    declare @operForms table (ID int)
    declare @complOpers table (ID int, REVOPERID int, DEVICEID int)
    declare @revs table (REVISIONID int, MAPOPERID int, MODELID int)

    insert into @operForms
    select OPS.ID
        from PR_OPERATIONS OPS with (nolock)
            left join COM_OPERATION_SKILL S with (nolock) on S.OPERFORM_ID=OPS.ID 
            left join COM_OPERATION_GROUP_SKILL SG with (nolock) on SG.OPERGROUP_ID=OPS.OPERGRID 
        where S.SKILLID=@skillID or SG.SKILLID=@skillID


    insert into @revs
    select  D.ID as ID, O.ID, D.MODELID
            from PR_REVISION D  with (nolock)
                join PR_MAP_OPER O with (nolock) on D.MAPID=O.MAPID 
                join @operForms F on O.OPERID=F.ID

    insert into @t
    select distinct D.MODELID as ID
        from @revs D 
            left join PR_MODELS M on D.MODELID=M.ID
            left join PR_REVISION R on D.REVISIONID=R.ID
        where M.S_S=1000016 and R.S_S=1000017

    /*declare @operForms table (ID int)
    declare @complOpers table (ID int, REVOPERID int, DEVICEID int)
    declare @devs table (DEVICEID int, MAPOPERID int, MODELID int)

    insert into @operForms
    select OPS.ID
        from PR_OPERATIONS OPS with (nolock)
            left join COM_OPERATION_SKILL S with (nolock) on S.OPERFORM_ID=OPS.ID 
            left join COM_OPERATION_GROUP_SKILL SG with (nolock) on SG.OPERGROUP_ID=OPS.OPERGRID 
        where ISNULL(S.SKILLID, SG.SKILLID)=@skillID

    insert into @complOpers
    select O.ID, O.REVOPERID, O.DEVICEID
        from PR_OPERATION O
        where O.OPERTYPEID in (select ID from @operForms) and O.S_S=1000032

    insert into @devs
    select D.ID as ID, O.ID, D.MODELID
            from PR_DEVICE D  with (nolock)
                join PR_MAP_OPER O with (nolock) on D.MAPID=O.MAPID 
                join @operForms F on O.OPERID=F.ID
            where D.S_S<>1000022

    insert into @t
    select D.MODELID as ID
        from @devs D 
            left join @complOpers PO on D.MAPOPERID=PO.REVOPERID and D.DEVICEID=PO.DEVICEID

                --left join @complOpers OPS on O.ID=OPS.REVOPERID and D.ID=OPS.DEVICEID 
            --where OPS.REVOPERID is null

    --insert into @t
    --select D.MODELID as ID
    --      from PR_DEVICE D  with (nolock)
    --          join PR_MAP_OPER O with (nolock) on D.MAPID=O.MAPID 
    --          join PR_OPERATIONS OPS with (nolock) on O.OPERID=OPS.ID 
    --          left join COM_OPERATION_SKILL S with (nolock) on S.OPERFORM_ID=OPS.ID 
    --          left join COM_OPERATION_GROUP_SKILL SG with (nolock) on SG.OPERGROUP_ID=OPS.OPERGRID 
    --          left join PR_OPERATION PO with (nolock) on O.ID=PO.REVOPERID and D.ID=PO.DEVICEID and OPS.ID=PO.OPERTYPEID
    --      where ISNULL(S.SKILLID, SG.SKILLID)=@skillID and (PO.REVOPERID is null or PO.S_S<>1000032)
    */
    return
end