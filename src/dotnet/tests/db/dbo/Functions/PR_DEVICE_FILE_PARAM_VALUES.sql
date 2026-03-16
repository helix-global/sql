CREATE FUNCTION [dbo].[PR_DEVICE_FILE_PARAM_VALUES]
(
	@deviceIDs nvarchar(max),
	@paramIDs nvarchar(max),
	@UserID int
)
RETURNS 
@ret TABLE 
(
	ID int,
	VALUE sql_variant,
	SN nvarchar(50),
	DEVICEID int
)
AS
BEGIN
	
	declare @modelTypeID int
	declare @tDevices table (ID int primary key)

	insert into @tDevices (ID)
	select ID from [COM_STR2TABLE_INT](@deviceIDs)

	
	declare @tParameters table (ID int primary key)

	insert into @tParameters (ID)
	select ID from [COM_STR2TABLE_INT](@paramIDs)

	select @modelTypeID = M.TYPEID
	from PR_DEVICE D 
		join PR_MODELS M on D.MODELID=M.ID
	where D.ID in(select top 1 ID from @tDevices)
	
	insert into @ret (ID, VALUE, SN, DEVICEID)
	SELECT      P.ID, P.VALUE, D.SN, P.DEVICEID
	FROM         [PR_DEVICE_PARAMS] P
			join PR_DEVICE D on P.DEVICEID=D.ID
			join @tParameters tmpp on P.ID=tmpp.ID
			join @tDevices tmpd on P.DEVICEID=tmpd.ID
		where P.MODELTYPEID=@modelTypeID
			and (isnull(P.SHAREPRM,0) = 1 or P.DEPARTMENTID IN(select ID from dbo.COM_ACCESS_DEPARTMENTS(@UserID, 8, getdate())))
			and P.VALUE is not null

	--SELECT      P.ID AS PARAMID, P.NAME
	--FROM         dbo.PR_DEVICE AS A LEFT OUTER JOIN
	--					  dbo.PR_MODELS AS M ON M.ID = A.MODELID LEFT OUTER JOIN
	--					  dbo.PR_MODELTYPE AS T ON T.ID = M.TYPEID LEFT OUTER JOIN
	--					  dbo.PR_MODELTYPE_PARAMS AS P ON P.TYPEID = T.ID
	--	where P.DATATYPE IN(7,8) and P.PARAMKIND=1 and M.TYPEID=@modelTypeID
	--		and A.ID in(select ID from [COM_STR2TABLE_INT](@deviceIDs))
	--		and (isnull(P.SHAREPRM,0) = 1 or dbo.COM_DEP_ACCESS2(T.DEPARTMENTID,8/*des*/,@UserID,getdate()) = 1)
	--group by P.ID, P.NAME
	
	RETURN 
END