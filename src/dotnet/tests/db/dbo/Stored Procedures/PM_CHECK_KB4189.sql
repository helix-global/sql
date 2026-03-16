-- +KB4519: 2023-01-03 : Исправление опечатки. Письмо для ЗАМов теперь не формируется. ЗАМы ставятся в копию для "начальника". {Maistrenko}
CREATE PROCEDURE [dbo].[PM_CHECK_KB4189] @UserID int
AS
BEGIN
  /*KB4189 */ --declare @UserID int = 26052

  set nocount on

  declare @DebugSwitch int = 0 -- 0 - нет отладки, 1 - отладка
  declare @now datetime
  set @now = GETDATE()
  declare @nowDate date  
  set @nowDate = CAST(@now as date)

  --в 7 утра (до 10)
  if @DebugSwitch = 0
    if datepart(hour,@now) < 7 or datepart(hour,@now) > 10 or dbo.COM_IS_WORKDAY(@nowDate,1) <> 1
    begin
      set nocount off
      return
    end
  
  --раз в день
  if exists (select * from PM_KB3824_NOTIFICATION_DATES where NTYPE = 4189 /*KB4189*/ and LASTDD >= @nowDate)
  begin
    set nocount off
    return
  end
  
 

--###############################################


	--cursor for uniq Employee send the letter
	declare @PM_DEV_PLAN_ID int
	declare @PM_DEV_PLAN_EMPLID int
	declare @PM_DEV_PLAN_REMARK nvarchar(max)
	declare @minDevPlanTaskDate date
	declare @maxDevPlanTaskDate date
	declare @mdifyByUser int
	declare @employeeDep int

	--- для всех найденных Development Plan удовлетворяющих условию ниже 
	declare cur cursor local read_only for 
	select ID, EMPLID, REMARK, S_MR from dbo.PM_DEV_PLAN P where P.S_S in (2130056 /* Not Approved */,2130058 /* Rejected*/)
	open cur
		WHILE 1=1
		BEGIN
			FETCH NEXT FROM cur INTO @PM_DEV_PLAN_ID, @PM_DEV_PLAN_EMPLID, @PM_DEV_PLAN_REMARK, @mdifyByUser;
			IF @@FETCH_STATUS<>0 BREAK;
	
			
			declare @employeeName nvarchar(250) = (select top 1 FULLNAME from DEF_USERS where EMPLOYEEID = @PM_DEV_PLAN_EMPLID )
			declare @dpLink varchar(max) = '<a href="a2l:\\Link=doc.pm_dev_plan.' + convert(varchar, @PM_DEV_PLAN_ID) + '">(Open Development Plan in PDB)</a>'

			-- вычисление мин и макс даты из задач по плану для упоминании в теле письма
			select 
				--PT.VNESHID as PM_DEV_PLAN_ID, 
				@minDevPlanTaskDate = MIN(PTT.DD), 
				@maxDevPlanTaskDate = MAX(PTT.DD)
			from 
				dbo.PM_DEV_PLAN_T PT with (nolock)
				join dbo.PM_DEV_PLAN_T_T PTT with (nolock) on PTT.VNESHID = PT.ID
			where 
				PT.VNESHID = @PM_DEV_PLAN_ID
			group by 
				PT.VNESHID
			-- вычисление мин и макс даты из задач по плану


			-- subject
			declare @subj nvarchar(200) = '[PDB-PM] Development Plan require attention'
			-- само тело письма
			declare @body nvarchar(max) = 'Dear All,<br><br>'  + CHAR(13)
			
			set @body = @body + 'The Development Plan for <b>' + @employeeName + '</b> ' + @dpLink + ' require attention.<br><br>' +CHAR(13)

			set @body = @body + 'Period: ' + dbo.COM_FORMAT_DATETIME(@minDevPlanTaskDate,1) + ' - ' + dbo.COM_FORMAT_DATETIME(@maxDevPlanTaskDate,1) + '.<br>' +CHAR(13)
			set @body = @body + 'Remark: ' + @PM_DEV_PLAN_REMARK + '.<br><br>' +CHAR(13)
			
			
			set @body = @body + 'Please do not answer this e-mail.<br>' + CHAR(13)
			set @body = @body + 'Production Database'
			set @body = N'<p style="font-family: ''Segoe UI'', Tahoma, Geneva, Verdana, sans-serif; font-size: small;">' + @body + N'</p>'
			set @body = N'<!--@UserID=' + cast(@UserID as nvarchar(max)) + N'-->'+char(13) + @body

			-- кому будем рассылать
			declare @sendToEmplId table (EMPLID int, [ROLE] int,[PM_DEV_PLAN_ID] int,[CC] nvarchar(max))
			delete from @sendToEmplId -- declare @sendToEmplId table (EMPLID int) не обнуляет ее :(
			set @employeeDep = dbo.COM_USER_DEPARTMENT(dbo.COM_USER_BY_EMPL(@PM_DEV_PLAN_EMPLID))
			if(@mdifyByUser = dbo.COM_USER_BY_EMPL(@PM_DEV_PLAN_EMPLID))
			begin
				--начальникам
				-- Если [Modify by] = [Employee], тогда отправлять уведомление сотрудникам из отдела [Employee] с [Role in Department] != Employee (
				-- Попозже изменили как вычислять начальников - "Всем кто входит в группу DH&VICE"
				
				--заполням список получателей - начальников
				insert into @sendToEmplId
					select U.EMPLOYEEID,E.ROLEINDEP,@PM_DEV_PLAN_ID,null
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
				select @PM_DEV_PLAN_EMPLID,-1,@PM_DEV_PLAN_ID,null
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

			--cursor for uniq Employee кому будем рассылать
			declare @empl int
			declare @CC nvarchar(max)
			declare curEmpl cursor local read_only for select distinct [EMPLID],[CC] from @sendToEmplId where [EMPLID] <> 1
			open curEmpl
				WHILE 1=1
				BEGIN
					FETCH NEXT FROM curEmpl INTO @empl,@CC;
					IF @@FETCH_STATUS<>0 BREAK;
			
					--declare @newBody nvarchar(max) = @body +'<br><br>' + str(@empl)  --test developer ()
					--set @empl = 3228							--test developer	Efimov Maksim
					
					if @DebugSwitch=1
					begin
						select top 1
							@empl=[a].[EMPLOYEEID]
						from [dbo].[DEF_USERS] [a] where [a].[ID]=@UserID
						exec MSG_SEND_TOEMPLOYEE2 @UserID, @empl, @CC,@subj, @body --@newBody
					end
					else
						exec MSG_SEND_TOEMPLOYEE2 @UserID, @empl, @CC,@subj, @body --@newBody
					--exec MSG_SEND_TOEMPLOYEE2 @UserID, 3228, @CC,@subj, @body -- test copy to developer
			
					--Print 'Send to Empl ' + STR(@empl)
				END
			close curEmpl;
			deallocate curEmpl;
			--cursor for uniq Employee кому будем рассылать
		END
	close cur;
	deallocate cur;

	
--###############################################

if @DebugSwitch = 0
begin
  --update last send date  
  update PM_KB3824_NOTIFICATION_DATES set LASTDD = @nowDate where NTYPE = 4189 /*KB4186*/
  if @@rowcount = 0 --если не проадейтилдась дата, 
    insert into PM_KB3824_NOTIFICATION_DATES (NTYPE,LASTDD) values (4189,@nowDate) --то просто вставляем запись с нужным кодом
end

set nocount off

END