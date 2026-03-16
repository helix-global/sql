CREATE PROCEDURE [dbo].[COM_ZEITARBEITREPORT_NOTIFICATION] @UserID int
AS
BEGIN
set nocount on

declare @now datetime = getdate()

if datepart(hour,@now) <> 8
begin
  set nocount off 
  return
end

declare @nMode int = 0
/*
 1 - в понедельник
 2 - во вторник
 3 - в 1 число месяца, если конец предыдущeго месяца среда
 4 - в 2 число месяца, если конец предыдущeго месяца среда  
*/

declare @dayOfWeek int = dbo.COM_DAY_OF_WEEK(@now)
if @dayOfWeek = 1
  set @nMode = 1
else if @dayOfWeek = 2
  set @nMode = 2
else
begin
 
  declare @endPrevMonth datetime = dbo.COM_ENCODE_DATE(year(@now),month(@now),1)
  set @endPrevMonth = dateadd(day,-1,@endPrevMonth)
  if dbo.COM_DAY_OF_WEEK(@endPrevMonth) = 3
  begin
  
    if day(@now) = 1
	  set @nMode = 3
	else if day(@now) = 2
	  set @nMode = 4
  
  end

end    

IF @nMode in (1,2,3,4)
BEGIN
    
	declare @prevWeek datetime 
	set @prevWeek = dateadd(week,-1,@now)
	
	declare @pWeekN int = (year(@prevWeek) * 100) + datepart(iso_week,@prevWeek) 
	
	declare @empl table (EMPID int not null)
	
	insert into @empl (EMPID)
	select A.ID 
	from COM_EMPLOYEE A with (nolock) 
	where A.S_S = 1
	  and A.ISTEMP = 1 
	  and A.EMAIL is not null 
	  and not exists(select F.ID 
	                from COM_ZEITARBEITREPORT F with (nolock) 
				    where F.EMPLID = A.ID
					  and F.WEEKN = @pWeekN
					  and F.S_S in (2130018,2130017) /*approved, applyed(not approved)*/
					  and isnull(F.MONTH_END,0) <> 1 
				  )
	  and not exists (select J.ID 
	                    from COM_ZEITARBEITREPORT_WASNOTIFYED J with (nolock)
						where J.EMPID = A.ID 
						  and J.WEEKN = @pWeekN
						  and J.NMODE = @nMode)
						  
  declare @oneEmplID int		
  declare @nname nvarchar(200)
  declare @msg nvarchar(max)
  				  
  declare nxx cursor local read_only for 
  select distinct EMPID from @empl
  open nxx 
  WHILE 1=1
  BEGIN
    FETCH NEXT FROM nxx INTO @oneEmplID
    IF @@FETCH_STATUS<>0 BREAK;
    
	select @nname = isnull(A.GIVENNAME,A.NAME) from COM_EMPLOYEE A with (nolock) where A.ID = @oneEmplID 
	set @nname = isnull(@nname,'') 
	
    set @msg = 'Dear '+@nname+',<br><br>"Time Sheet" document for previous week is missed.<br>Please apply this document.'
    set @msg = @msg + '<br><br>Please, do not answer this e-mail.<br>Production Database'
    
    exec MSG_SEND_TOEMPLOYEE @UserID, @oneEmplID, 'Time Sheet Notification', @msg
    insert into COM_ZEITARBEITREPORT_WASNOTIFYED (EMPID, WEEKN, NMODE) values (@oneEmplID,@pWeekN,@nMode)
    
  END
  close nxx;
  deallocate nxx; 					  

END						  
						  
set nocount off
END