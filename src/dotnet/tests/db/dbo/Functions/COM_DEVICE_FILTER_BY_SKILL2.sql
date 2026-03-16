-- =============================================
-- Author:      <Author,,Name>
-- Create date: <Create Date,,>
-- Description: <Description,,>
-- =============================================
CREATE FUNCTION [dbo].[COM_DEVICE_FILTER_BY_SKILL2]
(
    @skillID int
)
RETURNS @tRes TABLE (ID INT)
AS
BEGIN

    insert into @tRes (ID)
    select D.ID 
        from PR_DEVICE D  with (nolock)
            join PR_MAP_OPER O with (nolock) on D.MAPID=O.MAPID 
            join PR_OPERATIONS OPS with (nolock) on O.OPERID=OPS.ID 
            left join COM_OPERATION_SKILL S with (nolock) on S.OPERFORM_ID=OPS.ID 
            left join COM_OPERATION_GROUP_SKILL SG with (nolock) on SG.OPERGROUP_ID=OPS.OPERGRID 
            left join (select REVOPERID, DEVICEID from PR_OPERATION with (nolock)
                        where S_S<>1000032) PO on O.ID=PO.REVOPERID and D.ID=PO.DEVICEID
        where ISNULL(S.SKILLID, SG.SKILLID)=@skillID and PO.REVOPERID is null 
    
    RETURN 
END