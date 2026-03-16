-- =============================================
-- Author:		Maksim Efimov
-- Create date: 06.05.20222
-- Description:	Adding message to send to mobile device via PUSH message
-- KB5077	  : 07.11.2024 Fix format of PUSH message
-- KB5178	  : 15.01.2025 also add user from group 'Vacation Approval' (like DH&VICE)
-- =============================================

--@ProcessingType,1000184,@ContextID,@depID,@sSubj,@aLastMDT,@aLastMR

CREATE PROCEDURE [dbo].[MOBILE_PUSH_ADD_MSG_VACATION] 
	@DocumnetID int, @depHeadSettingCode int
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ToUserID int;
	DECLARE @Body varchar(1024);
	
	--Calculate HEAD of DEPS to whom send Approval Request
	DECLARE @HeadIDs table (HEADID int)
	DECLARE @EmplID int  = (select top 1 V.EMPLID from COM_VACATION V where V.ID = @DocumnetID);
	DECLARE @UserDepID  int = (select top 1 E.DEPID from COM_EMPLOYEE E where E.ID = @EmplID);
	DECLARE @UserID int = (select top 1 U.ID from DEF_USERS U where U.EMPLOYEEID = @EmplID);

	-- Get User ID's to whom send PUSH message, depending absence requested user is Head of Department or not
	if(isnull(@depHeadSettingCode,0) <> 1 and isnull(@depHeadSettingCode,0) <> 2)
	begin
		--Simple User  (not Head of Department)
		insert into @HeadIDs
		select distinct U.ID HEADID
		from DEF_USERS U
			left join COM_EMPLOYEE E on E.ID = U.EMPLOYEEID
			left join DEF_USERSTOGROUP G on G.USERID = U.ID 
		where 
			E.DEPID = @UserDepID
			and 
			E.S_S = 1  /* valid */
			and
			(G.GROUPID = 1114 /* HD&VICE role (can approve Absences) */
			 or
			 G.GROUPID = 1369 /* Vacation Approval */ )    /* KB5178 - also add user from group 'Vacation Approval'*/
			and
			U.ID <> @UserID /*Do not send to yourself*/
    end
	else
	begin 
		--User is Head of Department
		insert into @HeadIDs
		select dbo.COM_USER_BY_EMPL(S.DEFAULT4EMPLID) 
		from COM_DH_VP_SETTINGS S 
		where S.CODE = @depHeadSettingCode /* depending "Support" or "Production and R&D group" */
	end
	


	/* для тестов ####################################*/
	-- если получатель Михаил Введенский (IT) 
	-- то еще прислать PUSH разработчику 26052(Efimov)
	if(exists(select HEADID from @HeadIDs where HEADID = 998))
	begin
		insert 	into @HeadIDs (HEADID)
		values (26052)
	end  
	--else 
	--begin
	--	-- и все сотальные тоже
	--	insert 	into @HeadIDs (HEADID)
	--	values (26052)
	--end 
	/* для тестов ####################################*/


	

	--setting Body
	DECLARE @DBEG DATE
	DECLARE @DEND DATE
	DECLARE @VTYPE INT
	DECLARE @REMARK NVARCHAR(MAX)
	DECLARE @PERIODTYPE NVARCHAR(100)
	DECLARE @SHORTDURATION NVARCHAR(100)
	DECLARE @SHORTSTART TIME

	DECLARE @EmplName varchar(200)
	DECLARE @VTYPENAME varchar(200)

	DECLARE @EMERG_CASE int

	select 
			@DBEG = V.DBEG,
			@DEND = isnull(V.DEND, V.DBEG),
			@VTYPE = V.VACATIONTYPE,
			@REMARK = V.REMARK,
			@PERIODTYPE = T.NAME,
			@SHORTDURATION = TT.NAME,
			@SHORTSTART = V.SHORTSTART,

			@EmplName = E.NAME,
			@VTYPENAME = dbo.COM_LANG_EN(TTT.NAME),

			@EMERG_CASE = V.EMERG_CASE
			
	from 
		dbo.COM_VACATION as V
		left join DEF_ENUMERATION_T T on T.CODE = V.PERIODTYPE and T.ENUMOID=1000120
		left join DEF_ENUMERATION_T TT on TT.CODE = V.SHORTDURATION and TT.ENUMOID=1000122
		left join DEF_ENUMERATION_T TTT on TTT.CODE = V.VACATIONTYPE and TTT.ENUMOID = 1000119
		left join COM_EMPLOYEE E on E.ID = V.EMPLID
	where V.ID = @DocumnetID

	set @Body = 

		--KB5077 
		@EmplName + CHAR(10)
		+

		case when @VTYPE=30 then '' else 
			case when @PERIODTYPE is not null then '' else 'From ' end
		end 
		+
		dbo.COM_FORMAT_DATETIME(convert(date, @DBEG),1) 
		+ 
		case when @VTYPE=30 then 
			--short absence
			' from ' + CONVERT(VARCHAR(5),@SHORTSTART) + ' for ' +   @SHORTDURATION
		else
			--all other
			case when @PERIODTYPE is not null 
				--then ' for period: ' + dbo.COM_LANG_EN(@PERIODTYPE)				-- 1 day
				then ' ' + dbo.COM_LANG_EN(@PERIODTYPE)				-- 1 day
				else ' to ' +  dbo.COM_FORMAT_DATETIME(convert(date, @DEND),1)  -- more than 1 day
			end
		end
		+ 
		' ('+@VTYPENAME+')'
		+
		case when ISNULL(@REMARK,'') = '' then '' else ISNULL(' (' + @REMARK +')','') end
		
		

	--Title
	--DECLARE @Title varchar(200) = 'New Absence request (' + @EmplName + ')'
	DECLARE @Title varchar(200) = 'New Absence request' --KB5077		

	

	--для все HeadDeps and Deputy в цикле вставляем сообщения
	insert into MOBILE_PUSH_MESSAGES (TOUSERID, TITLE, BODY, DOCOID, DOCID, EMPLNAME, PAYLOADCOMMAND )
	select 
		H.HEADID, 
		@Title, 
		@Body, 
		1000184, 
		@DocumnetID, 
		@EmplName, 
		case
			when @EMERG_CASE is not null then 'emergency'
			when @VTYPE = 20 /*sick leave*/ then 'sickleave' 
			else 'absence' 
		end
		from @HeadIDs H
    
	SET NOCOUNT OFF;
END