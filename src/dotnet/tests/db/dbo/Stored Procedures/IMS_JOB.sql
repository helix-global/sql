CREATE procedure [dbo].[IMS_JOB] 
  @aUserID int
as 
SET nocount on

declare @now datetime = getdate()
declare @nowD date = cast(@now as date)

/*1 оповещение о наступлении next training date*/
if (datepart(hour,@now) > 6 ) and dbo.COM_IS_WORKDAY(@now,1) = 1 
begin
  

	declare @notifyRows table (ID int not null,PLANID int not null)
	insert into @notifyRows(ID,PLANID)
	select A.ID,B.ID 
	  from IMS_TRAINING_PLAN_EMPL A with (nolock)
	  left join IMS_TRAINING_PLAN B with (nolock) on B.ID = A.VNESHID
	 where B.SENDNOTYF > 0
	   and B.ID in (select NN.VNESHID from IMS_TRAINING_PLAN_NOTI NN with (nolock))
	   and isnull(B.LASTNOTIFYDD,'20000101') < @nowD
	   and dbo.IMS_NEXT_TRAINING_DATE(A.EMPLID,A.VNESHID) = dateadd(day,B.SENDNOTYF,@nowD)


  declare @planid int
  declare nxx cursor local read_only for 
  select distinct A.PLANID from @notifyRows A
  open nxx 
  WHILE 1=1
  BEGIN
 	FETCH NEXT FROM nxx INTO @planid
	IF @@FETCH_STATUS<>0 BREAK;
	
	declare @subj nvarchar(1024) = null
	select @subj = 'Notification by IMS Training Plan "'+A.NAME+'"' from IMS_TRAINING_PLAN A with (nolock) where A.ID = @planid
	
	declare @body nvarchar(max) = 'Dear All,<br><br>The following dates of next training are coming soon:<br>'
	select @body = @body + B.NAME+': '+convert(nvarchar,dbo.IMS_NEXT_TRAINING_DATE(A.EMPLID,A.VNESHID),103)+'<br>'
	from IMS_TRAINING_PLAN_EMPL A with (nolock)
	left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLID
	where A.ID in (select ID from @notifyRows where PLANID = @planid)
	
	set @body = @body + '<br>Please do not respond.<br>PDB.'
	
	declare @to nvarchar(1024) = ''
	select @to = isnull(@to,'') + B.EMAIL + '; '
	from IMS_TRAINING_PLAN_NOTI NN with (nolock)
	left join COM_EMPLOYEE B with (nolock) on B.ID = NN.EMPLID
	where NN.VNESHID = @planid
	  and B.EMAIL is not null
	
	exec MSG_SEND @aUserID, @to, null, @subj, @body
	
	update IMS_TRAINING_PLAN set LASTNOTIFYDD = @nowD where ID = @planid
	
  END
  close nxx;
  deallocate nxx;  


end


/*2 перевод тренингов из плана в in progress в дату тренинга*/
  
update A set A.S_S = 2130033/*in process*/
from IMS_TRAINING A
left join IMS_TRAINING_SCHEDULE_DATES B on B.ID = A.SCHEDULEDATEID
where A.S_S = 2130032/*planned*/
  and cast(B.DD as date) = @nowD
  and B.DD <= @now  /*KB2927*/
	


set nocount off