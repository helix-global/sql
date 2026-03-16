-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION dbo.SM_WORKORDER_DESCRIPTION
(
	@woId int
)
RETURNS nvarchar(4000)
AS
BEGIN
	
	DECLARE @ret nvarchar(4000) =''

	declare @t table (IID int, UID int, ISN nvarchar(50), IMODELNAME nvarchar(200), USN nvarchar(50), UMODELNAME nvarchar(200))


	declare @tR table (ID int, BOMID int, MODELID int)

	insert into @tR (ID, BOMID, MODELID)
	select distinct I.PARTID, I.BOMID, I.PARTMODELID
		from SM_SERVICEPROTOCOL_REMOVED R
			join PR_OPERATION_UNINSTALL U on R.REMOVEROWID=U.ID
			join PR_OPERATION_INSTALL I on U.INSTALLROWID=I.ID
			join SM_SERVICEPROTOCOL P on R.VNESHID=P.ID
		where P.WORKORDERID=@woId and P.S_S=2130016

	declare @tI table (ID int, BOMID int, MODELID int)

	insert  into @tI (ID, BOMID, MODELID)
	select distinct I.PARTID, I.BOMID, I.PARTMODELID
		from SM_SERVICEPROTOCOL_INSTALLED A
			join PR_OPERATION_INSTALL I on A.INSTALLROWID=I.ID
			join SM_SERVICEPROTOCOL P on A.VNESHID=P.ID
		where P.WORKORDERID=@woId and P.S_S=2130016

	insert into @t (IID, UID)
	select null,  R.ID
		from @tR R
			left join @tI I on R.BOMID=I.BOMID
		where I.BOMID is null

	insert into @t (IID, UID)
	select I.ID, R.ID
		from @tR R
			join @tI I on R.BOMID=I.BOMID

	insert into @t (IID, UID)
	select I.ID, null
		from @tR R
			right join @tI I on R.BOMID=I.BOMID
		where R.BOMID is null

	update @t set ISN = D.SN, IMODELNAME=M.NAME
		from @t T
			join PR_DEVICE D on T.IID=D.ID
			join PR_MODELS M on D.MODELID=M.ID

	update @t set USN = D.SN, UMODELNAME=M.NAME
		from @t T
			join PR_DEVICE D on T.UID=D.ID
			join PR_MODELS M on D.MODELID=M.ID


	select @ret = @ret + 'Alt ' + ISNULL(T.USN + ' (' + T.UMODELNAME + ')', '-') + ' - ' + 'Neu ' + ISNULL(T.ISN + ' (' + T.IMODELNAME + ')', '-') 
					+ CHAR(10) + CHAR(13)
		from @t T

	
	RETURN @ret

END