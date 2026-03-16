

CREATE PROCEDURE [dbo].[DA_CONCESSION_SND_MSG_TO_APPROVE_REQ] @UserID int
as

--5290008	Waiting for approval
--5290009	Waiting for QM approval
--5290010	Waiting for PLM approval
--5290011	Waiting for MD approval


--10	Issued
--20	Checked
--30	QM
--40	PLM
--50	MD


set nocount on

declare @nowDateTime datetime = GetDate()
declare @nowDate date = @nowDateTime
declare @nowTime time = @nowDateTime
declare @ReportName nvarchar(250) = 'DA_CONCESSION_SND_MSG_TO_APPROVE_REQ'
declare @ReportTime time = '7:00'

-- ############## ПРОВЕРКА НА РАБОЧИЕ ДНИ НЕДЕЛИ #########################################
if ([dbo].[COM_IS_WORKDAY] (@nowDateTime,1) = 0)
begin
   print 'exit (nobody need report at weekends)'
   set nocount off
   return
end


-- ################# ПРОВЕРКА НА УЖЕ ОТПРАВЛЕННЫЙ ОТЧЕТ ###########################################
if exists (select * from dbo.COM_SENDED_REPORTS where REPORT_NAME = @ReportName and @nowDate = CONVERT(date,LAST_SEND_DT))
begin
  print 'exit (today already done)'
  set nocount off
  return
end


-- ################# ПРОВЕРКА НАСТУПИЛО ЛИ ВРЕМЯ ДЛЯ ОТПРАВКИ НОВОГО ОТЧЕТ ########################################### 
print 'report send time: ' + CAST(@ReportTime as varchar(5))
print 'current time    : ' + cast(@nowTime as varchar(5))

if  @nowDateTime <= (CAST(@nowDATE as datetime) + CAST(@ReportTime as datetime)) 
begin
	print 'exit (it is not time to send)'
	set nocount off
	return
end


-- ########## SEND REPORT ############

declare @list table (ID int, DOC_NUMBER nvarchar(20), APPROVE_EMPLID int, AUTH_TYPE int)

/* find all not approved except "Checked" users */
insert into @list (ID, DOC_NUMBER, APPROVE_EMPLID, AUTH_TYPE)
select 
	DA.ID, 
	DA.NUMBER,
	case 
		--Waiting for QM approval
		when DA.S_S = 5290009 then DA.CHECKEDID
		--Waiting for PLM approval
		when DA.S_S = 5290010 then DA.RELEASEDID
		--Waiting for MD approval 
		when DA.S_S = 5290011 then DA.APPROVEDID
	end as APPROVE_EMPLID,
	case 
		--Waiting for QM approval
		when DA.S_S = 5290009 then 30
		--Waiting for PLM approval
		when DA.S_S = 5290010 then 40
		--Waiting for MD approval 
		when DA.S_S = 5290011 then 50
	end as AUTH_TYPE	-- need for next deputy finding
from 
	DA_CONCESSION DA with (nolock)
where 
	DA.S_S not in (1 /* Created */, 5290012 /* Rejecteed*/, 5290013 /*Approved*/, 5290008 /* checked */)


/* Add all other users from "Checked" */
insert into @list (ID, DOC_NUMBER, APPROVE_EMPLID, AUTH_TYPE)
	select 
		DA.ID, 
		DA.NUMBER,
		--null,
		CHK.EMPLID,
		20 as AUTH_TYPE -- need for next deputy finding
	from 
		DA_CONCESSION DA with (nolock)
		--@res res
		left join DA_CONCESSION_CHECKED CHK with (nolock) on CHK.VNESHID = DA.ID
	where 
		DA.S_S = 5290008 /* checked */
		and ISNULL(CHK.APPROVALSTATE,0) = 0
		and CHK.EMPLID is not null
		


/* prepear final table for sending mails */
declare @res table (ID int, DOC_NUMBER nvarchar(max), APPROVE_EMPLID  int, APPROVE_EMPL_MAIL nvarchar(MAX), DEPUTY_EMPLIDS nvarchar(MAX), DEPUTY_EMPL_MAILS nvarchar(MAX))
insert into @res
select 
	list.ID, list.DOC_NUMBER
	--,APPR.ID
	, list.APPROVE_EMPLID
	, dbo.GROUP_CONCAT(DISTINCT E_A.EMAIL) as APPROVE_EMPL_MAIL
	
	, isnull(dbo.GROUP_CONCAT(APPR_DEP.EMPLID),'') as DEPUTY_EMPLIDS
	, isnull(dbo.GROUP_CONCAT(E_D.EMAIL),'') as DEPUTY_EMPL_MAILS
	
from 
	@list list
	left join DA_CONCESSION_APPROVE_EMPL APPR with (nolock) on APPR.EMPLID = list.APPROVE_EMPLID and APPR.AUTHTYPE = list.AUTH_TYPE
	left join DA_CONCESSION_APPROVE_EMPL_DEPUTY APPR_DEP with (nolock) on APPR_DEP.VNESHID = APPR.ID
	left join dbo.COM_EMPLOYEE E_A with (nolock) on E_A.ID = list.APPROVE_EMPLID
	left join dbo.COM_EMPLOYEE E_D with (nolock) on E_D.ID = APPR_DEP.EMPLID
where 
	isnull(APPR_DEP.NOTIFY,0) = 0
group by
	list.ID, list.DOC_NUMBER, list.APPROVE_EMPLID


--select distinct APPROVE_EMPL_MAIL, DEPUTY_EMPL_MAILS from @res
--select * from @res

declare @Subj nvarchar(1024) = 'Concessions awaiting approval'
declare @Msg nvarchar(max) = ''
declare @CSS nvarchar(max) = '<style>
			        body {
			            font-family: Verdana, Geneva, Tahoma, sans-serif;
						font-size: 14px;
			        }
			        table {
			            width: 100%;
			            border-collapse: collapse;
			            font-family: Verdana, Geneva, Tahoma, sans-serif;
			            font-size: 12px;
			        }
			        thead {
			            background: #A2A2A2; 
						color: white; 
						font-family: Verdana, Geneva, Tahoma, sans-serif;
			        }
			        thead th {
			            padding: 4px;
			            text-align: left;
			            border: 1px solid white;
			        }
			        tbody {
			            background: whitesmoke;
			        }
			        tbody td {
			            border: 1px solid #ccc;
			            padding: 4px;
			        }
			        a {
			            color: #1565c0;
			            text-decoration: none;
			        }
			        a:hover {
			            text-decoration: underline;
			        }
			    </style>'

-- Create cursor for approvers emails
DECLARE @ApproverMail nvarchar(max);
DECLARE @DeputyMails nvarchar(max);

DECLARE curMails CURSOR FOR
select distinct APPROVE_EMPL_MAIL, DEPUTY_EMPL_MAILS from @res

-- Открываем курсор
OPEN curMails;

-- Цикл по записям таблицы Orders
FETCH NEXT FROM curMails INTO @ApproverMail, @DeputyMails;

WHILE @@FETCH_STATUS = 0
BEGIN

	--select @ApproverMail, @DeputyMails
	
	-- на всякий случай проверим что в запросе есть записи 
	-- Just in case, let's check that there are records in the query.
	if exists (select * from @res where APPROVE_EMPL_MAIL = @ApproverMail and DEPUTY_EMPL_MAILS = @DeputyMails)
	begin
		-- формируем текст письма
		-- create mail table body
		set @Msg = '<html>
					<head>' + 
					@CSS + 
					'</head>
						<body>
							Hello,<br>
							Following documents are awaiting your approval:<br><br>
							<table style="width: 100%;">
								<thead>
								<tr>
									<th>Document no.</th>
									<th>Document Type</th>
									<th>Department</th>
									<th>Model</th>
									<th>NAV Code</th>
									<th>Revision</th>
									<th>Specification</th>
								</tr>
								</thead>
								<tbody>
							' +

							(select
								dbo.GROUP_CONCAT_D(
								'<tr>' + 
								'<td><a href="a2l://doc/?ClassLabel=da_concession&ID='  + convert(nvarchar(max), DA.ID) + '">' + DA.NUMBER + '</a></td>' +
								'<td>' + ENUM.NAME + '</td>' +
								'<td>' + DEP.CODE + '</td>' + 
								'<td>' + MODEL.NAME + '</td>' +
								'<td>' + MODEL.CODE + '</td>' +
								'<td>' + REV.NAME + '</td>' +
								'<td>' + isnull(MODEL.SPEC,'&nbsp;') + '</td>' +
								'</tr>', '')
							from 
								@res res
								left join dbo.DA_CONCESSION DA with (nolock) on DA.ID = res.ID
								left join dbo.DEF_ENUMERATION_T ENUM with (nolock) on DA.DOCTYPE = ENUM.CODE and ENUM.ENUMOID = 5290003
								left join dbo.COM_DEPARTMENTS DEP with (nolock) on DEP.ID = DA.DEPID
								left join dbo.PR_REVISION REV with (nolock) on REV.ID = DA.REVID
								left join dbo.PR_MODELS MODEL with (nolock) on MODEL.ID = DA.MODELID
							where 
								APPROVE_EMPL_MAIL = @ApproverMail
								and
								DEPUTY_EMPL_MAILS = @DeputyMails
								) +

								'</tbody>
							</table>
							<br>
							<br>
							Production DataBase (PDB).<br>
							Please, do not answer.
						</body>
					</html>'

			--select @Msg
			
			exec dbo.MSG_SEND @UserID, @ApproverMail, @DeputyMails, @Subj, @Msg

	end
    
    -- Закрываем цикл и берем следующую запись из таблицы Orders
    FETCH NEXT FROM curMails INTO @ApproverMail, @DeputyMails;
END;

-- Закрываем курсор
CLOSE curMails;

-- Удаляем курсор
DEALLOCATE curMails;

-- ########## MARK AS SENDED TODAY ###########
insert into dbo.COM_SENDED_REPORTS (REPORT_NAME,LAST_SEND_DT)
values (@ReportName, GetDate())

set nocount off


--select * from COM_SENDED_REPORTS	
--delete from COM_SENDED_REPORTS where  ID > 7