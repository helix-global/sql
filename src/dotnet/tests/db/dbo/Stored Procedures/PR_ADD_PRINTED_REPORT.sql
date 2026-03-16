-- =============================================
-- Author:      <Author,,Name>
-- Create date: <Create Date,,>
-- Description: <Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PR_ADD_PRINTED_REPORT]
(
    @reportId int,
    @operIds nvarchar(max),
    @userId int
)
AS
BEGIN
    
    insert into PR_PRINTED_REPORTS ( OPERID, REPORTID, S_CDT, S_CR )
    select ID, @reportId, getdate(), @userId
        from dbo.COM_STR2TABLE_INT(@operIds)

END