CREATE function [dbo].[PR_NAVI_GET_URI]()
returns nvarchar(500) as 
begin
  declare @res nvarchar(500)
  select @res = A.NAVURL from PR_NAV_URLS A where A.SERVERNAME = @@SERVERNAME
  return @res
end