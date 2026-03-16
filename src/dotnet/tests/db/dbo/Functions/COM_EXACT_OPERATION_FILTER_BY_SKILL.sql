-- =============================================
-- Author:      <Author,,Name>
-- Create date: <Create Date,,>
-- Description: <Description,,>
-- =============================================
CREATE FUNCTION [dbo].[COM_EXACT_OPERATION_FILTER_BY_SKILL]
(
   @deviceID int, @skillID int
)
RETURNS TABLE
AS
RETURN
(   select O.ID 
    from PR_OPERATION O 
        join PR_OPERATIONS OPS with (nolock) on O.OPERTYPEID=OPS.ID 
        left join COM_OPERATION_SKILL S with (nolock) on S.OPERFORM_ID=OPS.ID 
        left join COM_OPERATION_GROUP_SKILL SG with (nolock) on SG.OPERGROUP_ID=OPS.OPERGRID 
    Where O.DEVICEID=@deviceID and O.S_S=1000032 and ISNULL(S.SKILLID, SG.SKILLID)=@skillID

)