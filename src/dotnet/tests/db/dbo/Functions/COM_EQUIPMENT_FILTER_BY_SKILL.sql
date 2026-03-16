-- =============================================
-- Author:      <Author,,Name>
-- Create date: <Create Date,,>
-- Description: <Description,,>
-- =============================================
CREATE FUNCTION [dbo].[COM_EQUIPMENT_FILTER_BY_SKILL]
(
    @skillID int
)
RETURNS @tRes TABLE (ID INT)
AS
BEGIN

    insert into @tRes (ID)
    select EQ.EQID 
        from  MNT_PLAN_EQ EQ
            join MNT_PLAN M on EQ.VNESHID=M.ID
            join PR_OPERATIONS OPS with (nolock) on M.OPERID=OPS.ID
            left join COM_OPERATION_SKILL S with (nolock) on S.OPERFORM_ID=OPS.ID 
            left join COM_OPERATION_GROUP_SKILL SG with (nolock) on SG.OPERGROUP_ID=OPS.OPERGRID 
        where ISNULL(S.SKILLID, SG.SKILLID)=@skillID 
    
    RETURN 
END