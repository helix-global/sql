CREATE PROCEDURE [dbo].[PM_NOPLAN_NOTIFICATION] @UserID int, @aMode int
AS
BEGIN
  set nocount on

  /* KB3388 */
 
  declare @now datetime
  declare @nowD date
  set @now = GETDATE()
  set @nowD = cast(@now as date) 
 
  if datepart(hour,@now) < 10 or datepart(hour,@now) > 13 
  begin
    set nocount off
    return
  end
  
  declare @settingID int
  declare @depid int
  declare @depCode nvarchar(50)
  
  select top 1 @settingID = A.ID
			  ,@depid = A.DEPID
			  ,@depCode = isnull(B.CODE,'NA')
  from PM_NP_NOTIFY A with(nolock)
  left join COM_DEPARTMENTS B with(nolock) on B.ID = A.DEPID
  where isnull(A.ENABL,0) = 1
    and isnull(cast(A.LAST_EXECDD as date),'20000101') < @nowD
 
  if @settingID is null
  begin
	set nocount off
	return
  end
  
  declare @tt table (EMPLID int)
  insert into @tt (EMPLID)
  select distinct A.EMPLID 
    from PM_NP_NOTIFY_T A 
   where A.VNESHID = @settingID
     and dbo.COM_IS_VACATIONDAY(@nowD,A.EMPLID) <> 1
     and dbo.COM_IS_WORKDAY3(@nowD,A.EMPLID) = 1
     and not exists ( select F.ID 
                       from PM_DEV_PLAN_T_T F with(nolock)
                       left join PM_DEV_PLAN_T G with(nolock) on G.ID = F.VNESHID
                       left join PM_DEV_PLAN H with(nolock) on H.ID = G.VNESHID
                       where F.DD = @nowD
                         and H.EMPLID = A.EMPLID
                         and H.S_S = 2130057 /*approved  нужно-ли? из KB3388 не очень понятно*/
                         and F.MHOUR > 0
                     )
  
  declare @mess nvarchar(max)
  declare @mess2 nvarchar(max) /*общее письмо начальнику*/
  declare @oneEmplID int
  declare @needSend int
  set @needSend = 0
  set @mess2 = 'Dear All,<br><br>Please find below the information about the employees without planned hours in Development Plans on '+convert(nvarchar,@nowD,104)+' of '+@depCode+' Department:<br><br>'
  set @mess2 = @mess2 + '<font size="-2"><table width="1000" cellspacing = "1" border="1" bordercolor="#ffffff"><tr><th>Date</th><th>Employee</th><th>Available Working Time (h)</th></tr>'
  
  declare nxx cursor local read_only for select EMPLID from @tt   
  open nxx 
  WHILE 1=1
  BEGIN
		FETCH NEXT FROM nxx INTO @oneEmplID;
		IF @@FETCH_STATUS<>0 BREAK;

		set @mess = null
		
		select @mess = 'Dear '+isnull(A.GIVENNAME,A.NAME) 
		      ,@needSend = 1
		      ,@mess2 = @mess2 + '<tr><td>'+convert(nvarchar,@nowD,104)+'</td><td>'+isnull(A.NAME,'NA')+'</td><td align="center">'+isnull(convert(nvarchar,dbo.COM_ATTENDANCE_TIME2(null,A.ID,@nowD)/60),'NA')+'</td></tr>'
		from COM_EMPLOYEE A with (nolock)
		where A.ID = @oneEmplID
				
		set @mess = @mess + ',<br><br>You don`t have the planned hours in Development Plan on '+convert(nvarchar,@nowD,104)
		set @mess = @mess + '<br><br>Please, do not answer this e-mail.<br>Production Database'
	    
		exec MSG_SEND_TOEMPLOYEE @UserID,@oneEmplID,'No Planned Hours in Development Plan',@mess
	
	    
  END
  close nxx;
  deallocate nxx;
  
  if @needSend = 1
  begin
  
       set @mess2 = @mess2 + '</table></font><br><br>Please, do not answer this e-mail.<br>Production Database'
       exec MSG_SEND_TODEP_HEADS @UserID,@depid,null,0,'Development Plan Report',@mess2
  
  end
  
  
  update PM_NP_NOTIFY set LAST_EXECDD = @now where PM_NP_NOTIFY.ID = @settingID
  
  set nocount off

END