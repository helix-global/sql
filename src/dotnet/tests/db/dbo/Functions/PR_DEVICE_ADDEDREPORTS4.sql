CREATE  function [dbo].[PR_DEVICE_ADDEDREPORTS4]( @DevCmpl int , @RevID int, @ModelID int, @MTID int)
returns nvarchar(max) with schemabinding
as
begin
  
   /* попытка ускорить связку PR_DEVICE_ADDEDREPORTS + PR_REPORT_USING2 в виде одной функции */

--   if not exists ( select A.ID from dbo.PR_REPORTS A with (nolock)  where A.MTID = @MTID)
--      return null


   declare @res nvarchar(max)
   set @res = ''

   select @res = @res + LTRIM(RTRIM(str(A.ID)))+';'
   from dbo.PR_REPORTS A with (nolock)
   where A.MTID = @MTID
     and A.S_S = 1000075 /* Approved */
     and A.USE_DEV_LIST = 1
     and (     (A.USE_DEV_PROD = 1 and @DevCmpl is null)
            or (A.USE_DEV_READY = 1 and @DevCmpl is not null)
          )
     and (  not exists (select B.ID from dbo.PR_REPORTS_T B with (nolock) where B.VNESHID = A.ID)
             or exists (select B.ID from dbo.PR_REPORTS_T B with (nolock) where B.VNESHID = A.ID and B.REVID = @RevID)
             or exists (select B.ID from dbo.PR_REPORTS_T B with (nolock) where B.VNESHID = A.ID and B.MODELID = @ModelID and B.REVID is null)
          )
       
   if LEN(@res) = 0
     return null
     
   return @res  

end;