--AZURE6030:2025-08-20: Removed hardcoded "vstarschenko@ipgphotonics.com".
--KB5240:2025-01-31: Instead of hardcoding the "Components Shipped" mailing will use department values from the settings for "Components Shipped".
--KB4583:2024-02-08: Removed useless parameters for [FC_NOTIFICATION_FOC1] procedure invokes.
CREATE PROCEDURE [dbo].[FC_NOTIFICATION]
AS
BEGIN
  declare @DepID int = 0

  if dbo.DEF_SYS_CONST_STR('com_remotelocation_code','NA') <> 'IPGL'  return
  
  
  declare @now datetime
  declare @notDate datetime
  set @now = GETDATE()
  
  if datepart(hour,@now) <> 8 return
  
  set @now = CAST (@now as date)
  select @notDate = CAST (NOTIFDD as date) from FC_NOTIFICATIONS A with (nolock) where A.NOTIFTYPE = 1
  
  if @notDate >= @now return
  
  update FC_NOTIFICATIONS set NOTIFDD = @now where NOTIFTYPE = 1
  if @@ROWCOUNT = 0
    insert into FC_NOTIFICATIONS (NOTIFTYPE,NOTIFDD) values (1,@now)

   /*KB4845 change eshcherbakov@ipgphotonics.com -> amashkin@ipgphotonics.com;vfomin@ipgphotonics.com */    

  exec FC_NOTIFICATION1 'jgoetz@ipgphotonics.com', 89, 'Jurgen', null
  exec FC_NOTIFICATION1 'wrerich@ipgphotonics.com', 89, 'Waldemar', 'amashkin@ipgphotonics.com;vfomin@ipgphotonics.com'
  exec FC_NOTIFICATION1 'ahetzel@ipgphotonics.com', 89, 'Alexej', null
  
  --exec FC_NOTIFICATION1 'bsivov@ipgphotonics.com', 151, 'Boris', null
  
  exec FC_NOTIFICATION1 'akhodakov@ipgphotonics.com', 160, 'Andrey', null
  exec FC_NOTIFICATION1 'vackermann@ipgphotonics.com', 160, 'Vladimir', 'amashkin@ipgphotonics.com;vfomin@ipgphotonics.com'
  
  --exec FC_NOTIFICATION1 'amamin@ipgphotonics.com', 196, 'Alexey', 'eshcherbakov@ipgphotonics.com;skoenig@ipgphotonics.com;azubenko@ipgphotonics.com'				--KB4206
  exec FC_NOTIFICATION1 'asatanowski@ipgphotonics.com', 196, 'Alexander', 'amashkin@ipgphotonics.com;vfomin@ipgphotonics.com;skoenig@ipgphotonics.com;azubenko@ipgphotonics.com'

  exec FC_NOTIFICATION1 'ashkarban@ipgphotonics.com', 82, 'Alexander', null
  exec FC_NOTIFICATION1 'mvladimirov@ipgphotonics.com', 170, 'Maxim', null
  
  exec FC_NOTIFICATION1 'dklochkov@ipgphotonics.com', 213, 'All', null

  /*KB5004*/
  /*
  exec FC_NOTIFICATION1 'vzuev@ipgphotonics.com', 214, 'All', 'aavdeev@ipgphotonics.com;mkubrikov@ipgphotonics.com;eobukhov@ipgphotonics.com;RLebedev@ipgphotonics.com'/*KB3812*//*KB4974*/
  */
  /*KB5004*/
  exec FC_NOTIFICATION1 'mkubrikov@ipgphotonics.com', 214, 'All', 'eobukhov@ipgphotonics.com;RLebedev@ipgphotonics.com'
  
  exec FC_NOTIFICATION1 'okinsel@ipgphotonics.com', 216, 'All', null
  exec FC_NOTIFICATION1 'djagodkin@ipgphotonics.com', 212, 'All', null
  exec FC_NOTIFICATION1 'sdubino@ipgphotonics.com', 215, 'All', 'imitrofanova@ipgphotonics.com;eviklenko@ipgphotonics.com'
  
  exec FC_NOTIFICATION1 'aheinrich@ipgphotonics.com', 143, 'Alexander', null --KB 2569

  --KB5240: Instead of hardcoding the "Components Shipped" mailing will use department values from the settings for "Components Shipped".
  --exec FC_NOTIFICATION_FOC1 'vstarschenko@ipgphotonics.com', 137 /*FBA-YFB*/, 'Valerij', ''
  --exec FC_NOTIFICATION_FOC1 'vstarschenko@ipgphotonics.com', 134 /*FBA-PFB*/, 'Valerij', ''
  --exec FC_NOTIFICATION_FOC1 'vstarschenko@ipgphotonics.com', 136 /*FBA-SFB*/, 'Valerij', ''
  declare [c] cursor local read_only for
    select distinct [a].[DEPID]
    from [dbo].[MSG_DELIVERYLIST] [a] with(nolock)
    where ([a].[DELIVERYTYPE]=2411) -- "Notification 'Components Shipped'"
  open [c]
  while 1=1
  begin
      fetch next from [c] into @DepID;
      if @@FETCH_STATUS<>0 break;
      exec [dbo].[FC_NOTIFICATION_FOC1] @DepID=@DepID
  end
  close [c]
  deallocate [c]
END