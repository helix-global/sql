-- =============================================
-- Author:      <Author,,Name>
-- Create date: <Create Date,,>
-- Description: <Description,,>
-- =============================================
CREATE FUNCTION [dbo].[COM_MAP_OPER_BY_SKILL]
(
    @deviceID int, @skillID int
)
RETURNS @ret table (ID int)
AS
BEGIN
    
    insert into @ret (ID)
        select O.ID
        from  PR_MAP_OPER O
            left join PR_DEVICE D with(nolock) on D.MAPID=O.MAPID
            left join PR_OPERATIONS OP with(nolock) on O.OPERID=OP.ID
            left join COM_OPERATION_SKILL S with(nolock) on OP.ID=S.OPERFORM_ID
            left join (select REVOPERID from PR_OPERATION with(nolock)
                        where DEVICEID=@deviceID and S_S<>1000032) PO on O.ID=PO.REVOPERID
        where D.ID=@deviceID AND S.SKILLID=@skillID and PO.REVOPERID is null
                
    insert into @ret (ID)
        select O.ID
        from PR_MAP_OPER O
            left join PR_DEVICE D with(nolock) on D.MAPID=O.MAPID
            left join PR_OPERATIONS OP with(nolock) on O.OPERID=OP.ID
            left join COM_OPERATION_GROUP_SKILL S with(nolock) on OP.OPERGRID = S.OPERGROUP_ID
            left join (select REVOPERID from PR_OPERATION with(nolock)
                        where DEVICEID=@deviceID and S_S<>1000032) PO on O.ID=PO.REVOPERID
        where D.ID=@deviceID AND S.SKILLID=@skillID and PO.REVOPERID is null
        except 
        select ID 
        from @ret

    RETURN
END