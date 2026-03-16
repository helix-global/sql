-- =============================================
-- Author:      <Author,,Name>
-- Create date: <Create Date,,>
-- Description: <Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PR_ASSIGN_PARALLEL_OPERATIONS]
    (@operId int, @userId int)
AS
BEGIN
    
    declare @devId int, @grId int, @mapId int, @visType int

    select @devId=O.DEVICEID, @grId=OPS.OPERGRID, @mapId=D.MAPID, @visType=G.VISTYPE
    from PR_OPERATION O with (nolock)
            join PR_OPERATIONS OPS with (nolock) on O.OPERTYPEID=OPS.ID
            join PR_OPERATIONS_GR G on OPS.OPERGRID=G.ID
            join PR_DEVICE D with (nolock) on O.DEVICEID=D.ID
        where O.ID=@operId

    if @visType in(3,4)
        update PR_OPERATION set USERINPROGRESS=@userId
        from PR_OPERATION O with (nolock)
            join PR_OPERATIONS OPS with (nolock) on O.OPERTYPEID=OPS.ID
            join PR_MAP_FLOW M with (nolock) on O.REVOPERID=M.OP_TO
            where O.DEVICEID=@devId and OPS.OPERGRID=@grId
                and O.ID<>@operId and O.S_S=1000032 /*pending*/
                        and USERINPROGRESS is null

END