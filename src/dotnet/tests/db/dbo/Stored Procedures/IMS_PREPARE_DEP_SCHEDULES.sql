CREATE PROCEDURE [dbo].[IMS_PREPARE_DEP_SCHEDULES] 
  @aContextID int, @aUserID int, @aMode int
AS
BEGIN
   set nocount on
   
   /*KB1850*/
   declare @dismissedEmplID int
   select top 1 @dismissedEmplID = B.ID 
   from IMS_TRAINING_SCHEDULE_EMPL A 
   left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLID
   where A.VNESHID = @aContextID
     and B.S_S = 1000092 /*dismissed*/

   if @dismissedEmplID is not null
   begin
      declare @errmsg nvarchar(max)
      select @errmsg = A.NAME from COM_EMPLOYEE A with (nolock) where A.ID = @dismissedEmplID
      set @errmsg = 'Employee record for '+@errmsg+' has "Dismissed" state. Unable to run "To Preparation".'
      raiserror(@errmsg,16,0)
      set nocount off
      return
   end

   delete from IMS_DEP_SCHEDULE where SCHEDULEID = @aContextID
   
   declare @now datetime = getdate()
   
   insert into IMS_DEP_SCHEDULE (GID,S_CR,S_CDT,S_S,SCHEDULEID,DEPID)
   select newid(),@aUserID,@now,1,@aContextID,M.DEPID
   from (
     select distinct B.DEPID
     from IMS_TRAINING_SCHEDULE_EMPL A 
     left join COM_EMPLOYEE B on B.ID = A.EMPLID
     where A.VNESHID = @aContextID
   )M
   
   
   declare @defaultTimeID int = null
   
   select @defaultTimeID = A.ID
   from IMS_TRAINING_SCHEDULE_DATES A
   where A.VNESHID = @aContextID
     and (select count(*) from IMS_TRAINING_SCHEDULE_DATES B where B.VNESHID = @aContextID) = 1 
   
   insert into IMS_DEP_SCHEDULE_T (GID,S_CR,S_CDT,VNESHID,EMPLID,SCHEDULEDATEID, NODATE)
   select newid(),@aUserID,@now
     , (select GB.ID from IMS_DEP_SCHEDULE GB where GB.SCHEDULEID = @aContextID and GB.DEPID = B.DEPID)
     , B.ID
     , @defaultTimeID
     , 0
     from IMS_TRAINING_SCHEDULE_EMPL A 
     left join COM_EMPLOYEE B on B.ID = A.EMPLID
    where A.VNESHID = @aContextID
   
   /*рассылка начальникам отделов*/
   /*
   declare @msg dbo.MSG_MESSAGES_BATCH
   
   insert into @msg (TEMPID1,TEMPID2,MSG_SUBJ,MSG_TO)
   select A.ID
     ,A.DEPID
     ,'IMS Training Schedule'
     ,dbo.MSG_DEP_HEADS_ADDR(A.DEPID,0)
   from IMS_DEP_SCHEDULE A
   left join IMS_TRAINING_SCHEDULE B on B.ID = A.SCHEDULEID
   where A.SCHEDULEID = @aContextID
   
   declare @dates nvarchar(max) = ''
   select @dates = case when len(@dates) > 0 then ', ' else '' end + convert(nvarchar,A.DD,104)+' '+dbo.COM_HHMM(A.DD)
   from IMS_TRAINING_SCHEDULE_DATES A with (nolock)
   where A.VNESHID = @aContextID
   
   update A set MSG_BODY = 'Dear All,<br><br>Please find enclosed link to schedule for training "'+F.NAME+'".<br>'+
        'Training plan: '+H.NAME+'<br>'+
        'Training type: '+J.NAME+'<br><br>'+
        'Available dates of training: '+isnull(@dates,'NA')+'<br><br>'+
        'Please review and approve <a href = "a2l:\\Link=doc.ims_dep_schedule.'+LTRIM(rtrim(str(A.TEMPID1)))+'">schedule document</a> in PDB.<br><br>'+
        'This e-mail was created automatically. Please do not reply.<br>PDB'
   from @msg A 
   left join IMS_DEP_SCHEDULE B with (nolock) on B.ID = A.TEMPID1
   left join IMS_TRAINING_SCHEDULE F with (nolock) on F.ID = B.SCHEDULEID
   left join IMS_TRAINING_PLAN H with (nolock) on H.ID = F.PLANID
   left join IMS_TRAINING_TYPE J with (nolock) on J.ID = H.TRTYPEID
   */
   
   /*update @msg set MSG_TO = 'dnorkin@ipgphotonics.com'*/
   /*
   exec MSG_SEND_BATCH @aUserID, @msg
   */
   
   set nocount off
END