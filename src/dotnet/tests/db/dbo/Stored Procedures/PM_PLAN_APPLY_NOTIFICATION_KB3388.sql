CREATE procedure [dbo].[PM_PLAN_APPLY_NOTIFICATION_KB3388] @ContextID int, @aUserID int
as
begin

    declare @subj nvarchar(500)
    declare @msg nvarchar(max)
    declare @dep nvarchar(250)
    declare @empl nvarchar(250)
    declare @depid int
    
    set @subj = 'Development Plan Created Notification'

	select @dep = isnull(C.CODE,'NA')
		  ,@empl = isnull(B.NAME,'NA')
		  ,@depid = B.DEPID
	from PM_DEV_PLAN A with(nolock)
	left join COM_EMPLOYEE B with(nolock) on B.ID = A.EMPLID
	left join COM_DEPARTMENTS C with(nolock) on C.ID = B.DEPID
	where A.ID = @ContextID
	
	set @msg ='Dear All,<br><br>'
			   + 'The following Development Plan has been created:<br><br>'
			   + '<a href="a2l:\\Link=doc.pm_dev_plan.' + convert(varchar,@ContextID) +'">[link to Development Plan]</a>'
			   + '<br><br>'
			   + 'Department: '+@dep+'<br>'
			   + 'Employee: '+@empl+'<br><br>'
			   + 'Please do not answer this e-mail.<br>'
			   + 'Production Database'
			   
	
    exec MSG_SEND_TODEP_HEADS @aUserID, @depid , null, 0, @subj, @msg
    
	
end