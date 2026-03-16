-- =============================================
-- Author:      <Author,,Name>
-- Create date: <Create Date,,>
-- Description: <Description,,>
-- =============================================
create FUNCTION [dbo].[COM_MAP_OPER_BY_SKILL_REV]
(
    @revID int, @skillID int
)
RETURNS @ret table (ID int)
AS
BEGIN
    
    insert into @ret (ID)
        select O.ID
        from  PR_MAP_OPER O with(nolock)
            left join PR_REVISION R with(nolock) on R.MAPID=O.MAPID
            left join PR_OPERATIONS OP with(nolock) on O.OPERID=OP.ID
            left join COM_OPERATION_SKILL S with(nolock) on OP.ID=S.OPERFORM_ID
        where R.ID=@revID AND S.SKILLID=@skillID 
                
    insert into @ret (ID)
        select O.ID
        from PR_MAP_OPER O with(nolock)
            left join PR_REVISION R with(nolock) on R.MAPID=O.MAPID
            left join PR_OPERATIONS OP with(nolock) on O.OPERID=OP.ID
            left join COM_OPERATION_GROUP_SKILL S with(nolock) on OP.OPERGRID = S.OPERGROUP_ID
        where R.ID=@revID AND S.SKILLID=@skillID 
        except 
        select ID 
        from @ret

    RETURN
END