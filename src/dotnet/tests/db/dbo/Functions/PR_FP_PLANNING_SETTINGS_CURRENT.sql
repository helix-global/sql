CREATE FUNCTION [dbo].[PR_FP_PLANNING_SETTINGS_CURRENT]
(
)
RETURNS 
@ret TABLE (OPERTASKID int
		, OPERDRAWID int
		, OPERPREPAREID int
		, OPERPREPARENAME nvarchar(100)
		, OPERTASKNAME nvarchar(100)
		, OPERDRAWNAME nvarchar(100)
		, MTID int)
AS
BEGIN
    
    declare @id int

    select @id = MAX(ID)
        from PR_FP_PLANNING_SETTINGS 
        where S_S=4180004

    insert into @ret
    select S.OPERTASKID,S.OPERDRAWID,S.OPERPREPAREID,O.NAME,O1.NAME,O2.NAME,S.MTID
        from PR_FP_PLANNING_SETTINGS S
            left join PR_OPERATIONS O with (nolock) on S.OPERPREPAREID=O.ID
            left join PR_OPERATIONS O1 with (nolock) on S.OPERTASKID=O1.ID
            left join PR_OPERATIONS O2 with (nolock) on S.OPERDRAWID=O2.ID
        where S.ID=@id


    RETURN 
END