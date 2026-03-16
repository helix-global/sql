CREATE function [dbo].[PR_NAV_MODEBYMODEL] (@depID int, @mtID int, @modelID int, @mode int)
returns date
as
begin
    declare @res date
    
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

if @SettingID is null
   return null

select @res = case @mode 
   when 1 then A.M2_MAT
   when 2 then A.M2_TIME
   when 3 then A.M2_DEV
   end
from PR_NAV_DEPMODES A with (nolock) 
where A.ID = @SettingID
	
                
    return @res
end