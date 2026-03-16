/*
KB2517: Send notification letter to Department persons in mailgroup wich emplyee of Dev Plan is belong, that devplan need to approve
KB2517: Отправка сообщения пользователям департамента указанным в группе рассылки которому принадлежит сотрудник указанный в плане 

EFIMOV MV
*/


CREATE PROCEDURE [dbo].[PM_PLAN_NEED_APPROVE_NOTIFICATION] @ContextID int, @aUSERID int
as
begin

	declare @DELIVERYTYPE int = 2400 --Notification about new Development Plan need to Approve
    declare @DELIVERYDEPID int 
    declare @EMPLID int
    declare @REMARK varchar(max)
    
    declare @SUBJ varchar(max) = 'PM Delivery Plan must to be Approve'
    declare @HTML varchar(max)


	select 
		@DELIVERYDEPID = [dbo].[COM_EMPLOYEE_DEP] (DP.EMPLID, DP.DD),
		@EMPLID = DP.EMPLID,
		@REMARK = DP.REMARK
	from 
		PM_DEV_PLAN DP with(nolock)
	where 
		DP.ID = @ContextID
	
	set @HTML ='<span style="font: 1.2em Calibri; font-weight:bold">'
			   + 'A new Development Plan has appeared in PDB, which must be approve:'
			   + '</span><br><br>'
			   + '<span style="font: 1em Calibri">'
			   + (select top 1 E.NAME from COM_EMPLOYEE E with(nolock) where E.ID = @EMPLID)
			   + ' - '
			   + (select top 1 D.NAME from COM_DEPARTMENTS D with(nolock) where D.ID = @DELIVERYDEPID)
			   + ''
			   +'&nbsp;&nbsp;-&nbsp;&nbsp;'
			   +'<a href="a2l:\\Link=doc.pm_dev_plan.' + convert(varchar,@ContextID) +'">link to PDB</a>'
			   + '<br>'
	
	if(isnull(@REMARK,'') <> '')
	begin
		set @HTML = @HTML + '<br>plan remark:<br>' + @REMARK
	end
		   
	-- exec [dbo].[MSG_SEND_TOEMPLOYEE] 26052, 3228 , @SUBJ, @HTML
	exec MSG_SEND_TODELIVERYGROUP @aUSERID, @DELIVERYTYPE, @DELIVERYDEPID, @SUBJ, @HTML
	
end