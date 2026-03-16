-- +KB4519: 2023-01-03 : Исправление опечатки. Письмо для ЗАМов теперь не формируется. ЗАМы ставятся в копию для "начальника". Фикс для предотвращения "пустого" письма. {Maistrenko}
CREATE procedure [dbo].[PM_PLAN_STATUS_CHANGE_NOTIFICATION_KB4189] @UserID int,  @devPlanID int, @oldStatus int, @newStatus int, @mdifyByUser int
as
begin

/* TEST */
--declare @devPlanID int = 176
--declare @UserID int = 26052
/* TEST */

	declare @mdifyByUserName Nvarchar(250)  = (select top 1 FULLNAME from DEF_USERS where ID = @mdifyByUser)
	declare @employee int
	declare @employeeDep int
	declare @employeeName nvarchar(250)
	declare @dpLink nvarchar(max)
	declare @minDevPlanTaskDate date
	declare @maxDevPlanTaskDate date
	
	select 
		--@mdifyByUser = ISNULL(P.S_MR,S_CR)
		@employee = P.EMPLID
		,@employeeDep = dbo.COM_USER_DEPARTMENT(dbo.COM_USER_BY_EMPL(P.EMPLID))
		,@employeeName = (select top 1 FULLNAME from DEF_USERS where EMPLOYEEID = P.EMPLID) 
		,@dpLink = '<a href="a2l:\\Link=doc.pm_dev_plan.' + convert(varchar,P.ID) + '"> (Open Development Plan in PDB) </a>'
	from 
		dbo.PM_DEV_PLAN P
	where 
		--P.S_S in (2130056 /* Not Approved */,2130058 /* Rejected*/) and
		P.ID = @devPlanID
	

	-- кому будем рассылать
	declare @sendToEmplId table ([EMPLID] int,[ROLE] int,[CC] nvarchar(max))

	if(@mdifyByUser = dbo.COM_USER_BY_EMPL(@employee))
	begin
		--начальникам
		-- Если [Modify by] = [Employee], тогда отправлять уведомление сотрудникам из отдела [Employee] с [Role in Department] != Employee (
		-- Попозже изменили как вычислять начальников - "Всем кто входит в группу DH&VICE"
		
		--заполням список получателей - начальников
		insert into @sendToEmplId
			select U.EMPLOYEEID,E.ROLEINDEP,null
			from DEF_USERS U
				left join COM_EMPLOYEE E on E.ID = U.EMPLOYEEID
			where (E.DEPID = @employeeDep)
				and (E.ROLEINDEP in (10,100)) -- KB4519: ·Начальников и ЗАМов определять по полю Role in Department
				--and (dbo.DEF_USERINGROUP7(U.ID,'DH&VICE') = 1)
	end
	else
	begin
		--тому кому назначен план
		-- [Modify by] != [Employee], тогда отправлять уведомление о необходимости обработки получателю [Employee]
		
		--вставляем в список получателей только тому кто указан в данно PM_DEV_PLAN
		insert into @sendToEmplId
		select @employee,-1,null
	end

	-- KB4519: ·ЗАМов (Deputy) ставить в копию, вместо создания отдельного письма для них.
	update @sendToEmplId
		set [CC]=[b].[CC]
	from
		(
		select [dbo].[GROUP_CONCAT_D](cast([e].[EMAIL] as nvarchar(max)),';') [CC]
		from @sendToEmplId [a]
			inner join [dbo].[COM_EMPLOYEE] [e] with(nolock) on [e].[ID]=[a].[EMPLID]
		where not ([a].[ROLE] in (100,-1))
			and ([a].[EMPLID]<>1)
		) [b]
	where [ROLE]=100
	delete from @sendToEmplId where not ([ROLE] in (100,-1))

	-- вычисление мин и макс даты из задач по плану для упоминании в теле письма
	select 
		--PT.VNESHID as PM_DEV_PLAN_ID, 
		@minDevPlanTaskDate = MIN(PTT.DD), 
		@maxDevPlanTaskDate = MAX(PTT.DD)
	from 
		dbo.PM_DEV_PLAN_T PT with (nolock)
		join dbo.PM_DEV_PLAN_T_T PTT with (nolock) on PTT.VNESHID = PT.ID
	where 
		PT.VNESHID = @devPlanID
	group by 
		PT.VNESHID
	-- вычисление мин и макс даты из задач по плану
	
	-- subject
	declare @subj nvarchar(200) = '[PDB-PM] Development Plan status was modified'
	-- само тело письма
	declare @body nvarchar(max) = 'Dear All,<br><br>'  + CHAR(13)
	
	set @body = @body + 'The Development Plan for <b>' + @employeeName + '</b> ' + @dpLink + '<br>was modified by <b>' + @mdifyByUserName + '</b>.<br><br>' +CHAR(13)
	set @body = @body + 'Period: ' + isnull(dbo.COM_FORMAT_DATETIME(@minDevPlanTaskDate,1),'') + ' - ' + isnull(dbo.COM_FORMAT_DATETIME(@maxDevPlanTaskDate,1),'') + '.<br>' +CHAR(13)
	set @body = @body + 'Old status: <b>'+ isnull([dbo].[COM_LANG_EN]((select top 1 NAME from DEF_CLASS_STATES where OID = @oldStatus)),'?') + '</b>.<br>' +CHAR(13)
	set @body = @body + 'New status: <b>'+ isnull([dbo].[COM_LANG_EN]((select top 1 NAME from DEF_CLASS_STATES where OID = @newStatus)),'?') + '</b>.<br><br>' + CHAR(13)
	
	set @body = @body + 'Please do not answer this e-mail.<br>' + CHAR(13)
	set @body = @body + 'Production Database'
	set @body = N'<p style="font-family: ''Segoe UI'', Tahoma, Geneva, Verdana, sans-serif; font-size: x-small;">' + @body + N'</p>'
	set @body = N'<!--@UserID=' + isnull(cast(@UserID as nvarchar(max)),'{null}') + N'-->'+char(13) +
			N'<!--@devPlanID=' + isnull(cast(@devPlanID as nvarchar(max)),'{null}') + N'-->'+char(13) +
			N'<!--@oldStatus=' + isnull(cast(@oldStatus as nvarchar(max)),'{null}') + N'-->'+char(13) +
			N'<!--@newStatus=' + isnull(cast(@newStatus as nvarchar(max)),'{null}') + N'-->'+char(13) +
			N'<!--@mdifyByUser=' + isnull(cast(@mdifyByUser as nvarchar(max)),'{null}') + N'-->'+char(13) +
			N'<!--@minDevPlanTaskDate=' + isnull(convert(nvarchar(max),@minDevPlanTaskDate,126),'{null}') + N'-->'+char(13) +
			N'<!--@maxDevPlanTaskDate=' + isnull(convert(nvarchar(max),@maxDevPlanTaskDate,126),'{null}') + N'-->'+char(13) +
			+ @body

	--cursor for uniq Employee send the letter
	declare @empl int
	declare @CC nvarchar(max)
	declare cur cursor local read_only for select distinct [EMPLID],[CC] from @sendToEmplId where EMPLID <> 1
	open cur
		WHILE 1=1
		BEGIN
			FETCH NEXT FROM cur INTO @empl,@CC;
			IF @@FETCH_STATUS<>0 BREAK;
	
			--set @body = @body +'<br><br>' + str(@empl)  --test developer ()
			--set @empl = 3228							--test developer	Efimov Maksim
			exec MSG_SEND_TOEMPLOYEE2 @UserID, @empl, @CC, @subj, @body
		END
	close cur;
	deallocate cur;

end