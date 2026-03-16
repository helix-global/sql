-- =============================================
-- Author:      <Author,,Name>
-- Create date: <Create Date,,>
-- Description: <Description,,>
-- =============================================
CREATE FUNCTION [dbo].[COM_PREPARATORY_FILTER_BY_SKILL]
(
    @skillID int
)
RETURNS @tRes TABLE (ID INT)
AS
BEGIN

    insert into @tRes (ID)
    select P.ID
        from PR_PREPARATORY P
            join PR_OPERATIONS O on P.OPERID=O.ID
            left join COM_OPERATION_SKILL S with (nolock) on S.OPERFORM_ID=O.ID 
            left join COM_OPERATION_GROUP_SKILL SG with (nolock) on SG.OPERGROUP_ID=O.OPERGRID 
        where ISNULL(S.SKILLID, SG.SKILLID)=@skillID 
            
    RETURN 
END