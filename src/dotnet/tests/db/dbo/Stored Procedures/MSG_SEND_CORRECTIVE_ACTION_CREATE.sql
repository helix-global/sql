
CREATE PROCEDURE [dbo].[MSG_SEND_CORRECTIVE_ACTION_CREATE] @CorrActionID int
AS
BEGIN

/*TEST*/
--DECLARE @CorrActionID int = 8
/*TEST*/

DECLARE @subj varchar(250) = 'You have been added to a Corrective Action Team.'
DECLARE @models varchar(MAX) = ''

/* список моделей по corr_action */
select 
	@models = @models + ', ' + '<br/>' + MODEL.NAME 
from FC_CORRACTIONS_MODELS AM
	join PR_MODELS MODEL on AM.MODELID = MODEL.ID
where 
	VNESHID = @CorrActionID

/* Данные по пользователям в команде для рассылки */
declare @mailData table (EMPL_ID int, [EMPL_NAME] VARCHAR(250), EMPL_EMAIL varchar(250), ROLE_NAME VARCHAR(50), AFFECTED_MODELS VARCHAR(MAX), INTR_DATE DATE, CONTR_DATE DATE, PDB_LINK VARCHAR(250), BODY VARCHAR(MAX))
insert into @mailData
select 
	--CORRACTION.*,
	--CORRACTION.ID,
	EMPLOYEE.ID EMPL_ID, 
	EMPLOYEE.NAME EMPL_NAME,
	EMPLOYEE.EMAIL EMPL_EMAIL,
	TEAMROLE.NAME ROLE_NAME,
	case when @models = '' then '' else SUBSTRING(@models,3,len(@models)) end AFFECTED_MODELS,
	convert (date,CORRACTION.IDATE) INTR_DATE,
	convert (date, CORRACTION.PDATE) CONTR_DATE,
	'a2l:\\Link=doc.fc_corr_actions.' + CONVERT(varchar,CORRACTION.ID) PDB_LINK,

	'You have been added to the Team to take Corrective Action ' 
	+ '<a href="'
	+ 'a2l:\\Link=doc.fc_corr_actions.' + CONVERT(varchar,CORRACTION.ID)					-- PDB LINK  
	+ '">link to PDB</a>'
	+ ' as ' 
	+ '<b>' + TEAMROLE.[NAME] + '</b>'														-- ROLE IN TEAM
	+ ' for models: ' + '<br/>'
	+ '<span>'
	+ case when @models = '' then '' else SUBSTRING(@models,3,len(@models)) end				-- MODELS LIST
	+ '</span>.' + '<br/><br/>' 
	+ 'The duration of the Corrective Action is from '
	+ '<b>' + [dbo].[COM_FORMAT_DATETIME](CORRACTION.IDATE, 1) + '</b>'						-- INTRODUCTION DATE
	+ ' to ' 
	+ '<b>' + [dbo].[COM_FORMAT_DATETIME](CORRACTION.PDATE, 1) + '</b>.'					-- CONTROL DATE
	+ '<br/>' 
	+ '<br/>'
	+ 'Please, do not answer this e-mail.' + '<br/>'
	+ 'Production Database' + '<br/>' as body

from 
	dbo.FC_CORRACTIONS CORRACTION
	join dbo.FC_CORRACTIONS_TEAM TEAM on TEAM.VNESHID = CORRACTION.ID
	left join dbo.COM_EMPLOYEE EMPLOYEE on EMPLOYEE.ID = TEAM.EMPLID
	left join (SELECT CODE, NAME from DEF_ENUMERATION_T where ENUMOID = 1000128) as TEAMROLE on TEAMROLE.CODE = TEAM.TEAMROLE
where
	CORRACTION.ID = @CorrActionID

/* cursor */
DECLARE @EMPLID int
DECLARE @BODY varchar(MAX)
DECLARE db_cursor CURSOR FOR  select EMPL_ID, BODY from @mailData
OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @EMPLID, @BODY

WHILE @@FETCH_STATUS = 0  
BEGIN
	
	--exec  dbo.MSG_SEND_TOEMPLOYEE 26052, 3228 , @subj, @BODY
	exec  dbo.MSG_SEND_TOEMPLOYEE 26052, @EMPLID , @subj, @BODY

FETCH NEXT FROM db_cursor INTO @EMPLID, @BODY 
END 

CLOSE db_cursor  
DEALLOCATE db_cursor 

END