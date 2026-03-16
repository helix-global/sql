-- =============================================
-- Author:      <Author,,Name>
-- Create date: <Create Date,,>
-- Description: <Description,,>
-- =============================================
CREATE FUNCTION [dbo].[PR_FP_PLANNING_SETTINGS_CURRENT2]
(
)
RETURNS 
@ret TABLE (OPERTASKID int, OPERDRAWID int, OPERPREPAREID int, OPERPREPARENAME nvarchar(100), OPERTASKNAME nvarchar(100), OPERDRAWNAME nvarchar(100))
AS
BEGIN
    
    declare @taskId int, @taskRev int, @taskName nvarchar(100)
    declare @prepId int, @prepRev int, @prepName nvarchar(100)
    declare @drawId int, @drawRev int, @drawName nvarchar(100)

	select @taskRev = max(REVN)
		from PR_OPERATIONS O
		where O.S_S=1000059 and O.ID in(select ID from dbo.PR_FP_PLANNING_OPERATIONS(1))

	select @taskId = O.ID, @taskName = O.NAME
		from PR_OPERATIONS O
		where O.S_S=1000059 and O.ID in(select ID from dbo.PR_FP_PLANNING_OPERATIONS(1)) and REVN=@taskRev

	select @prepRev = max(REVN)
		from PR_OPERATIONS O
		where O.S_S=1000059 and O.ID in(select ID from dbo.PR_FP_PLANNING_OPERATIONS(2))

	select @prepId = O.ID, @prepName = O.NAME
		from PR_OPERATIONS O
		where O.S_S=1000059 and O.ID in(select ID from dbo.PR_FP_PLANNING_OPERATIONS(2)) and REVN=@prepRev

	select @drawRev = max(REVN)
		from PR_OPERATIONS O
		where O.S_S=1000059 and O.ID in(select ID from dbo.PR_FP_PLANNING_OPERATIONS(3))

	select @drawId = O.ID, @drawName = O.NAME
		from PR_OPERATIONS O
		where O.S_S=1000059 and O.ID in(select ID from dbo.PR_FP_PLANNING_OPERATIONS(3)) and REVN=@drawRev

    insert into @ret (OPERTASKID, OPERDRAWID, OPERPREPAREID, OPERPREPARENAME, OPERTASKNAME, OPERDRAWNAME)
	values(@taskId, @drawId, @prepId, @prepName, @taskName, @drawName)
  
    RETURN 
END