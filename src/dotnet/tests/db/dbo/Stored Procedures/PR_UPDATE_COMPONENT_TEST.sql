CREATE procedure [dbo].[PR_UPDATE_COMPONENT_TEST] @UserID int, @CompletedDeviceID int
as 
set nocount on

declare @componentTests table (ID int primary key identity, TestId int, TestBatchN nvarchar(100), ItemId int, DepId int, DeviceId int)
insert into @componentTests (TestId, TestBatchN, ItemId, DepId, DeviceId)
select C.ID, C.BATCHN, CI.ID, C.DEPID, CI.DEVICEID
from PR_COMPONENT_TEST C with (nolock)
left join PR_COMPONENT_TEST_ITEM CI with (nolock) on CI.VNESHID=C.ID
where C.S_S = 3180005 /*In Testing*/
  and CI.DEVICEID in (select PARTID from PR_DEVICE_BOM with (nolock) where DEVICEID=@CompletedDeviceID and UNINSTALLOPERID is null)

if (not exists (select * from @componentTests))
begin
  return
end


while (exists (select * from @componentTests))
begin
  
  declare @TestId int
  declare @ItemId int
  declare @TestBatchN nvarchar(100)
  declare @DepId int
  declare @DeviceID int
  select top(1) @TestId=TestId, @ItemId=ItemId, @TestBatchN=TestBatchN, @DepId=DepId, @DeviceID=DeviceID
  from @componentTests

  declare @hasFailureReports int = (case when exists (select * from FC_REPORT with (nolock) where DEVICEID=@DeviceID) then 1 else 0 end)

  update PR_COMPONENT_TEST_ITEM
  set APPROVED = (case @hasFailureReports when 1 then 2 /*Not Approved*/ else 1 /*Approved*/ end)
  where ID=@ItemId

  if (exists (select * from PR_COMPONENT_TEST C with (nolock) where C.ID=@TestId and C.S_S<>3180006 /*Tested*/)
      and not exists (select * from PR_COMPONENT_TEST C with (nolock) left join PR_COMPONENT_TEST_ITEM CI with (nolock) on CI.VNESHID=C.ID where C.ID=@TestId and isnull(CI.APPROVED, 0)=0))
  begin

    update PR_COMPONENT_TEST
    set S_S = 3180006 /*Tested*/
    where ID=@TestId

    -- send notification

    declare @DeliveryType int = 1800 /*Рассылка Component Test*/
    declare @sSubj nvarchar(300)
    declare @sBody nvarchar(max)

  	set @sSubj = 'The Component Test "' + @TestBatchN + '" tested'

    set @sBody = 'Dear All,<br><br>The Component Test <a href = "a2l:\\Link=doc.pr_component_test.'+LTRIM(rtrim(str(@TestId)))+'">'+@TestBatchN+'<a>'
		set @sBody = @sBody + ' has been tested.<br/><br/>'
  	set @sBody = @sBody +'<br><br>Please, do not answer this e-mail.<br>Production Database'	  
	  
    exec MSG_SEND_TODELIVERYGROUP2 @UserID, @DeliveryType, @DepId, @sSubj, @sBody, 0

    -- send notification

  end

  delete from @componentTests where ID = (select top(1) ID from @componentTests)

end

set nocount off