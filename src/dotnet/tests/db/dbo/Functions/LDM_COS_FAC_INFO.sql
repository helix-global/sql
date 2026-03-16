CREATE function [dbo].[LDM_COS_FAC_INFO] (@CosN int, @aMode int)
returns @Bars table (CHANNEL int, BARN int, QTBOXES nvarchar(max), BARSN nvarchar(50), FIRSTNTBOXID int)
as 
begin

/*
@aMode - 1 - добить CHANNEL до 6
*/

declare @CosPrmID int = dbo.LDM_SETTING_INT('fac_operation1_cosN_paramid',0)
declare @CosStr nvarchar(100) = rtrim(ltrim(cast(@CosN as nvarchar(100))))

declare @BarBomItemID int = dbo.LDM_SETTING_INT('fac_operation1_bar_bomitemid',0)
declare @NtboxBomItemID int = dbo.LDM_SETTING_INT('fac_operation1_ntbox_bomitemid',0)
declare @PrmChannel int = dbo.LDM_SETTING_INT('fac_operation1_channel(X)_paramid',0)
declare @PrmDiodeN int = dbo.LDM_SETTING_INT('fac_operation1_diodeN(Y)_paramid',0)
declare @PrmBarN int = dbo.LDM_SETTING_INT('fac_operation1_barN_paramid',0)

declare @chips table (ID int not null, CHANNEL int, NTBOXSN nvarchar(200), NTBOXID int, DIODEN int)

insert into @chips (ID,CHANNEL,NTBOXSN,NTBOXID,DIODEN)
select B.DEVICEID
      ,dbo.PR_DEVICE_PARAM_INT(B.DEVICEID,@PrmChannel) as CHANNEL
      ,NTBOX.SN
      ,NTBOX.ID
      ,dbo.PR_DEVICE_PARAM_INT(B.DEVICEID,@PrmDiodeN) as DIODEN
from PR_OPERATION_PARAMS A with (nolock)
left join PR_OPERATION B with (nolock) on B.ID = A.OPERID
left join PR_DEVICE NTBOX with (nolock) on NTBOX.ID = dbo.PR_DEVICE_BOMITEM(B.DEVICEID,@NtboxBomItemID)
where A.PARAMID = @CosPrmID
  and A.INDEX_STR = @CosStr
  
insert into @Bars (CHANNEL, BARN)   
select distinct 
  dbo.PR_DEVICE_PARAM_INT(A.ID,@PrmChannel) as CHANNEL
  ,dbo.PR_DEVICE_PARAM_INT(A.ID,@PrmBarN) as BARN
from PR_DEVICE A with (nolock)
where A.ID in (select BB.ID from @chips BB)

declare @chOne int
declare @boxesL nvarchar(max)
declare nxx cursor local read_only for 
select CHANNEL from @Bars
open nxx 
WHILE 1=1
BEGIN
    FETCH NEXT FROM nxx INTO @chOne;
    IF @@FETCH_STATUS<>0 BREAK;
    
	set @boxesL = ''
	select @boxesL = @boxesL + ',' + NTBOXSN from 
  	   (select distinct A.NTBOXSN from @chips A where A.CHANNEL = @chOne ) M order by NTBOXSN
	
	update @Bars set QTBOXES = @boxesL where CHANNEL = @chOne
    
END
close nxx;
deallocate nxx;

update @Bars set QTBOXES = substring(QTBOXES,2,9999) where QTBOXES like ',%'
update @Bars set BARSN = 'BAR'+ltrim(rtrim(str(BARN)))

update @Bars set FIRSTNTBOXID = (select top 1 NTBOXID from @chips order by CHANNEL, DIODEN)

if @aMode = 1
begin
  
  declare @i int = 1
  while @i < 7
  begin
     if not exists (select * from @Bars where CHANNEL = @i)
     begin
        insert into @Bars (CHANNEL) values (@i)
     end
     set @i = @i + 1
  end
  
end

return

end