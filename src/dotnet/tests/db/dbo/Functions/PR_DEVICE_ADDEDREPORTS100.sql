CREATE function [dbo].[PR_DEVICE_ADDEDREPORTS100](@DeviceID int, @DevCmpl datetime, @RevID int, @ModelID int, @MTID int)
returns nvarchar(max) with schemabinding
as
begin

   declare @res nvarchar(max)
   set @res = ''
/*
   select @res = @res + cast(A.ID as nvarchar)+';'
   from dbo.PR_REPORTS A with (nolock)
   where A.MTID = @MTID
     and A.S_S = 1000075 /* Approved */
     and A.USE_DEV_LIST = 1
     and (     (A.USE_DEV_PROD = 1 and @DevCmpl is null)
            or (A.USE_DEV_READY = 1 and @DevCmpl is not null)
          )
     and (   A.FULLMT = 1
           or exists (select B.ID from dbo.PR_REPORTS_T B with (nolock) where B.VNESHID = A.ID and B.REVID = @RevID)
           or exists (select B.ID from dbo.PR_REPORTS_T B with (nolock) where B.VNESHID = A.ID and B.MODELID = @ModelID and B.REVID is null)
          ) 
*/
if @DevCmpl is null
begin

   select @res = @res + cast(A.ID as nvarchar)+';'
   from dbo.PR_REPORTS A with (nolock)
   where A.MTID = @MTID
     and A.S_S = 1000075 /* Approved */
     and A.USE_DEV_LIST = 1
     and A.USE_DEV_PROD = 1 
     and (   A.FULLMT = 1
           or exists (select B.ID from dbo.PR_REPORTS_T B with (nolock) where B.VNESHID = A.ID and B.REVID = @RevID)
           or exists (select B.ID from dbo.PR_REPORTS_T B with (nolock) where B.VNESHID = A.ID and B.MODELID = @ModelID and B.REVID is null)
          ) 

end
else
begin

   select @res = @res + cast(A.ID as nvarchar)+';'
   from dbo.PR_REPORTS A with (nolock)
   where A.MTID = @MTID
     and A.S_S = 1000075 /* Approved */
     and A.USE_DEV_LIST = 1
     and A.USE_DEV_READY = 1 
     and (   A.FULLMT = 1
           or exists (select B.ID from dbo.PR_REPORTS_T B with (nolock) where B.VNESHID = A.ID and B.REVID = @RevID)
           or exists (select B.ID from dbo.PR_REPORTS_T B with (nolock) where B.VNESHID = A.ID and B.MODELID = @ModelID and B.REVID is null)
          ) 

end


       
   if LEN(@res) = 0
     return null
     
   return @res  

end;