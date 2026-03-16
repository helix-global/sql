CREATE PROC [dbo].[FC_NOTIFICATIONS_CONTROLDATE_SEND] (@before bit, @IDs varchar(max), @UserID int)
as
begin

	/* TEST DATA */
	--DECLARE @before bit = 1
	--DECLARE @IDs varchar(max) = '55,56'
	--DECLARE @UserID int = 26052
	/* TEST DATA */
	
	--------------------subject for letter (comming or expired)
	DECLARE @subj varchar(250);
	if(@before = 1)
	set @subj = 'Control Date of Corrective actions is coming to the end'
	else 
	set @subj = 'Expires Control Date by Corrective actions'
	
	
	-------------------- emails from corrective action team for send letter to
	DECLARE @mails VARCHAR(MAX) = ''
	select 
		 @mails = @mails + '; ' + isnull(E.EMAIL,'')
	from 
	FC_CORRACTIONS_TEAM T
	left join COM_EMPLOYEE E on E.ID = T.EMPLID
	where T.VNESHID in (select * from [COM_STR2TABLE_INT](@IDs)) 
	
	if (@mails='')
	return 
	else
	set @mails = SUBSTRING(@mails, 3, LEN(@mails)-2)
	
	
	--generate rows for taqble in letter body
	DECLARE @rows VARCHAR(MAX) = ''
	select 
		@rows = @rows + 
	   '
		
		<tr>
			<td>' + isnull(STATE.NAME,'') + '</td>
			<td>' + isnull(dbo.COM_FORMAT_DATETIME(convert(date,CORRACT.S_CDT),1),'') + ' </td>
			<td>' + isnull(DEPS.NAME,'') + ' </td>
			<td>' + isnull(FACODES.NAME,'') + ' </td>
			<td>' + isnull(FCODES.NAME,'') + ' </td>
			<td>' + isnull(convert(varchar,CORRACT.DESCR),'') + ' </td>
			<td>' + isnull(dbo.COM_FORMAT_DATETIME(CORRACT.IDATE,1),'') + ' </td>
			<td>' + isnull(dbo.COM_FORMAT_DATETIME(CORRACT.PDATE,1),'') + ' </td>
			<td><a href = "a2l:\\Link=doc.fc_corr_actions.'+ltrim(rtrim(str(CORRACT.ID)))+'">Link</a></td>
		</tr>
		
		'
		--STATE.NAME,
		--CORRACT.S_CDT DATECREATION,
		--DEPS.NAME DEPNAME,
		--FACODES.NAME FAILUREANALYSISCODE,
		--FCODES.NAME FAILURECODE,
		--CORRACT.DESCR DESCRIPION,
		--CORRACT.IDATE INTRODUCTIONDATE,
		--CORRACT.PDATE CONTROLDATE
	from 
		FC_CORRACTIONS CORRACT with(nolock)
		left join dbo.DEF_CLASS_STATES STATE with(nolock) on STATE.OID = CORRACT.S_S
		left join COM_DEPARTMENTS DEPS with(nolock) on DEPS.ID = CORRACT.DEPID
		left join FC_FAILUREANALYSISCODES FACODES with(nolock) on FACODES.ID =  CORRACT.ANALYSISCODEID
		left join FC_FAILURECODES FCODES with(nolock) on FCODES.ID = CORRACT.FAILURE_CODE
	where 
		CORRACT.ID in (select * from [COM_STR2TABLE_INT](@IDs))
	
	
	
	
	
	-- genreate letter BODY with CSS style
	DECLARE @body varchar(MAX) = '
	<html>
	<head>
	<style>
	
	body {
		font-family: Calibri;
	}
	
	table.customTable {
	  font-family: Calibri;
	  
	  width: 100%;
	  background-color: #FFFFFF;
	  border-collapse: collapse;
	  border-width: 1px;
	  border-style: solid;
	  color: #000000;
	}
	
	table.customTable th {
	  border-width: 1px;
	  border-color: white;
	  border-style: solid;
	  padding: 5px;
	}
	
	table.customTable td {
	  border-width: 1px;
	  border-color: #B5B5B5;
	  border-style: solid;
	  padding: 5px;
	} 
	
	table.customTable thead {
	  background-color: #B5B5B5;
	}
	
	</style>
	</head>
	<body>
	Dear All,<br/>
	' + 
	case when @before = 1 then 'The Corrective Actions are coming to the end:' else 'The Corrective Actions are expired:' end
	+ '
	<br/><br/>
	<table class="customTable">
	    <thead>
		<tr>
			<th>Состояние</th>
			<th>Date of Creation</th>
			<th>Department</th>
			<th>Failure Analysis Code</th>
			<th>Failure Code</th>
			<th>Description</th>
			<th>Introduction Date</th>
			<th>Control Date</th>
			<th>Link</th>
			</thead>
		</tr>
		</thead>
	' + @rows +'
	
	</table>
	<br/>
	Please, do not answer this e-mail.<br/>
	Production Database.'
	
	-- send e-mail (put in queue to send)
	exec dbo.MSG_SEND2 @UserID, @mails, null, @subj, @body

end