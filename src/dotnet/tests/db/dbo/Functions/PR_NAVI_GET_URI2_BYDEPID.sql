create function [dbo].[PR_NAVI_GET_URI2_BYDEPID](@DepID int)
returns nvarchar(500) as 
begin
  /*на основе dbo.PR_NAVI_GET_URI2 для KB4537*/
  declare @settingID int
  declare @res nvarchar(500)
  
  select @settingID = A.ID,@res = A.NAVURL from PR_NAV_URLS A with(nolock) where A.SERVERNAME = @@SERVERNAME
  
  declare @overSettingID int
  declare @res2 nvarchar(500)
    
  select top 1 @overSettingID = B.ID, @res2 = B.NAVURL
  from PR_NAV_URLS_T B with(nolock)
  where B.VNESHID = @settingID
    and B.DEPID in (select ID from dbo.COM_GETPARENT_DEPARTMENTS(@DepID,1))
    
  if @overSettingID is not null
       return @res2
  
  return @res
end