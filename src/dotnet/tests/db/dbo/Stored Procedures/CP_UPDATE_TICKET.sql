CREATE PROCEDURE [dbo].[CP_UPDATE_TICKET] (@aMTID int, @DeviceID int, @UserID int)
AS
BEGIN
set nocount on

/*
   процедура _заранее_ создает тикеты под изделия, если тип моделей изделия фигурирует в подписках
   чтобы иметь возможность распечатать номер тикета еще до отгрузки изделия 
*/

IF exists (select A.ID from MSG_FILENOTIFICATIONS A with (nolock) where A.MTID = @aMTID)
BEGIN

	if exists (select B.ID from CP_TICKETS B with (nolock) where B.DEVICEID = @DeviceID and B.AUTOCREATED = 1)
	begin
	  /* тикет есть - создавать не надо */
	  set nocount off
	  return
	end  

	declare @mtid int
	declare @depid int

	select @mtid = D.TYPEID
		  ,@depid = B.DEPARTMENTID
	from PR_DEVICE A with (nolock)
	left join PR_PRORDER B with (nolock) on B.ID = A.ORDERID
	left join PR_MODELS D with (nolock) on D.ID = A.MODELID
	where A.ID = @DeviceID
	             
	  
	declare @ticketID int

	insert into CP_TICKETS(GID,S_CR,S_CDT,S_S,DEPID,DEVICEID,EXPIRED,AUTOCREATED)
	values (newid(),@UserID,getdate(),2000005/*reserved*/,@depid,@DeviceID,dateadd(day,270,getdate()),1)
	/*EXPIRED потом скорректирутся при выгрузке*/

	set @ticketID = @@identity

	exec CP_TICKET_CHECK @ticketID, @UserID

END

set nocount off
END