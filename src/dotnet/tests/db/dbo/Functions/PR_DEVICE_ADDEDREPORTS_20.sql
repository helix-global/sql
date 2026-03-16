CREATE function [dbo].[PR_DEVICE_ADDEDREPORTS_20](@DevCmpl datetime, @RevID int)
returns nvarchar(max)
as
begin

   declare @res nvarchar(max)
   set @res = ''

   select @res = @res + LTRIM(RTRIM(str(A.ID)))+';'
   from dbo.PR_REPORTS A with (nolock)
   where A.ID in (select BB.REPORTID from PR_REPORTS_REVISIONS BB with (nolock) where BB.REVID = @RevID)
     and A.S_S = 1000075 /* Approved */
     and A.USE_DEV_LIST = 1
     and (     (A.USE_DEV_PROD = 1 and @DevCmpl is null)
            or (A.USE_DEV_READY = 1 and @DevCmpl is not null)
          )
	   
   if LEN(@res) = 0
     return null
     
   return @res  

end;