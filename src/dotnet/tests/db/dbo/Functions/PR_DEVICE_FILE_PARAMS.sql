CREATE FUNCTION [dbo].[PR_DEVICE_FILE_PARAMS]
(
	@deviceIDs nvarchar(max),
	@UserID int
)
RETURNS 
@ret TABLE 
(
	PARAMID int,
	NAME nvarchar(300)
)
AS
BEGIN
	
	declare @modelTypeID int
	declare @t table (ID int)

	insert into @t (ID)
	select ID from [COM_STR2TABLE_INT](@deviceIDs)

	select @modelTypeID = M.TYPEID
	from PR_DEVICE D 
		join PR_MODELS M on D.MODELID=M.ID
	where D.ID in(select top 1 ID from @t)
	
	insert into @ret (PARAMID, NAME)
	SELECT      P.ID AS PARAMID, P.NAME
	FROM         dbo.PR_DEVICE AS A LEFT OUTER JOIN
						  dbo.PR_MODELS AS M ON M.ID = A.MODELID LEFT OUTER JOIN
						  dbo.PR_MODELTYPE AS T ON T.ID = M.TYPEID LEFT OUTER JOIN
						  dbo.PR_MODELTYPE_PARAMS AS P ON P.TYPEID = T.ID
		where P.DATATYPE IN(7,8) and P.PARAMKIND=1 and M.TYPEID=@modelTypeID
			and A.ID in(select ID from [COM_STR2TABLE_INT](@deviceIDs))
			and (isnull(P.SHAREPRM,0) = 1 or dbo.COM_DEP_ACCESS2(T.DEPARTMENTID,8/*des*/,@UserID,getdate()) = 1)
	group by P.ID, P.NAME
	
	RETURN 
END