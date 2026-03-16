CREATE PROCEDURE [dbo].[MSG_PRORDER_CDATE_CHANGED] @OrderID int, @UserID int, @oldDate date, @newDate date
AS
BEGIN
    /*KB4073*/
    set nocount on

	declare @mess nvarchar(max)
	declare @mess2 nvarchar(max)
	declare @subj nvarchar(max)
	declare @depid int
	declare @mtid int
	
	set @subj = 'PO: Confirmed date was changed'
	
	select @depid = A.DEPARTMENTID
		,@mess = '<td>'+isnull(A.NN,'NA')+'</td><td>'+isnull(A.NN2,'NA')+'</td><td>'+isnull(A.NN3,'NA')+'</td><td>'+isnull(B.NAME,'NA')+'</td><td>'+isnull(convert(nvarchar,A.EXPDATE,104),'')+'</td>'
	from PR_PRORDER A with(nolock)
	left join COM_CUSTOMER B with(nolock) on B.ID = A.CUSTOMERID
	where A.ID = @OrderID
	
	if dbo.MSG_DELIVERYTYPE_INDEP_EXISTS(1616,@depid) <> 1
	begin
		set nocount off	
		return
	end	
	
	select top 1 @mtid = B.TYPEID
	from PR_PRORDER_T A with(nolock)
	left join PR_MODELS B with(nolock) on B.ID = A.MODELID
	where A.PRORDERID = @OrderID
	
	if @mtid is not null
	begin
		select @subj = @subj + ', MT: '+A.NAME 
		from PR_MODELTYPE A with(nolock)
		where A.ID = @mtid
	end
	
	set @mess = @mess + '<td>'+isnull(convert(nvarchar,@oldDate,104),'')+'</td><td>'+isnull(convert(nvarchar,@newDate,104),'')+'</td>'
	
	
	set @mess2 = 'Dear All,<br><br>The following Confirmed dates was changed:<br><br><font size="-2"><table width="1000" cellspacing = "1" bgcolor="#eeeeee" border="1" bordercolor="#ffffff">'
	set @mess2 = @mess2 + '<tr><th>Production Order</th><th>Source Number</th><th>External Number</th><th>Customer</th><th>Planned Date</th><th>Previous Confirmed Date</th><th>New Confirmed Date</th></tr>'

	set @mess = @mess2 + '<tr>'+ @mess + '</tr></table></font><br><br>Please, do not answer this e-mail.<br>Production Database'


    exec MSG_SEND_TODELIVERYGROUP4 @UserID,1616,@depid,@subj,@mess,null 
    /*exec MSG_SEND_TOUSER @UserID,3,@subj,@mess*/
	
	set nocount off	
END