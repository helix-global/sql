create function [dbo].[PR_NAV_SETTINGID_BYMODEL] (@depID int, @mtID int, @modelID int)
returns int
as
begin
    
declare @SettingID int

select top 1 @SettingID = A.ID 
from PR_NAV_DEPMODES A with (nolock) 
where A.DEPID = @depID 
  and A.MTID = @mtID
  and exists (select B.ID from PR_NAV_DEPMODES_T B with (nolock) where B.VNESHID = A.ID and B.MODELID = @modelID)

if @SettingID is null
begin
	select top 1 @SettingID = A.ID 
	from PR_NAV_DEPMODES A with (nolock) 
	where A.DEPID = @depID 
	  and A.MTID = @mtID
	  and not exists (select B.ID from PR_NAV_DEPMODES_T B with (nolock) where B.VNESHID = A.ID)
end

if @SettingID is null
begin
	select top 1 @SettingID = A.ID 
	from PR_NAV_DEPMODES A with (nolock) 
	where A.DEPID = @depID 
	  and A.MTID is null
	  and not exists (select B.ID from PR_NAV_DEPMODES_T B with (nolock) where B.VNESHID = A.ID)
end

    return @SettingID
end