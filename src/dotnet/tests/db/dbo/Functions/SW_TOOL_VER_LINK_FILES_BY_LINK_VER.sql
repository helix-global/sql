CREATE FUNCTION [dbo].[SW_TOOL_VER_LINK_FILES_BY_LINK_VER]
(
	@VerId int
)
RETURNS @t table (ID int
				, GID uniqueidentifier
				  ,S_CR int
				  ,S_CDT datetime
				  ,S_MR int
				  ,S_MDT datetime
				  ,ARC int
				  ,VERID int
				  ,FILENAME nvarchar(255)
				  ,FILESIZE int
				  ,FILEDESC ntext
				  ,FILEDATE datetime
				  ,FILEBLOB image
				  ,FILEPREVIEW image
				  ,FILEGROUP int
				  ,STID int
				  ,VNESHID int
				  --,OVERGROUPID int --KB3680
				  ,FILEGROUPNAME nvarchar(255)
				  ,FILEGRPOVERRIDE int 
				  )
AS
BEGIN
	
	declare @tVers table (ID int,OVERGROUP int)

	insert into @tVers(ID,OVERGROUP) 
	select distinct S.VERID,S.OVERGROUP
			from SW_TOOL_VERSION_LINKS S with(nolock)
				where S.VNESHID=@VerId


	while exists(select distinct S.VERID
			from SW_TOOL_VERSION_LINKS S with(nolock)
				where S.VNESHID in (select ID from @tVers)
					and S.VERID not in (select ID from @tVers))
	begin
		insert into @tVers(ID) 
		select distinct S.VERID
			from SW_TOOL_VERSION_LINKS S with(nolock)
				where S.VNESHID in (select ID from @tVers)
					and S.VERID not in (select ID from @tVers)
					
	end


	insert into @t (ID,GID,S_CR,S_CDT,S_MR,S_MDT,ARC,VERID,FILENAME,FILESIZE
				  ,FILEDESC,FILEDATE,FILEBLOB,FILEPREVIEW,FILEGROUP
				  ,STID,VNESHID, FILEGROUPNAME,FILEGRPOVERRIDE )
	select F.ID
				  ,F.GID
				  ,F.S_CR
				  ,F.S_CDT
				  ,F.S_MR
				  ,F.S_MDT
				  ,F.ARC
				  ,F.VERID
				  ,F.FILENAME
				  ,F.FILESIZE
				  ,F.FILEDESC
				  ,F.FILEDATE
				  ,F.FILEBLOB
				  ,F.FILEPREVIEW
				  ,isnull(OVG.OVERGROUPID, isnull(V.OVERGROUP,F.FILEGROUP)) --OVG.OVERGROUPID
				  ,F.STID
				  ,@VerId
				  ,FG.NAME
				  ,case when isnull(OVG.OVERGROUPID,0) = 0 then 0 else 1 end -- KB3680
				  --,NGR.ID
				  --,OVG.OVERGROUPID -- KB3680
		from SW_TOOL_VER_FILES F with(nolock)
			join @tVers V on F.VERID=V.ID
			/* KB3680 */
			left join SW_TOOL_VER_LINK_FILES_OVERGROUP OVG with (nolock) on OVG.VERID = @VerId and OVG.FILEID = F.ID
			left join SW_TOOL_GROUPS_FGROUP FG with(nolock) on FG.ID = F.FILEGROUP
			--left join (
			--	select 
			--		FG.NAME,
			--		FG.ID
			--	from 
			--		SW_TOOL_VERSIONS SWTV with(nolock)
			--		left join SW_TOOLS SWT with(nolock) on SWTV.TOOLID = SWT.ID
			--		left join SW_TOOL_GROUPS_FGROUP FG with(nolock) on FG.VNESHID = SWT.GROUPID
			--	where 
			--		SWTV.ID = @VerId) NGR on NGR.NAME = FG.NAME
				



	RETURN 
END