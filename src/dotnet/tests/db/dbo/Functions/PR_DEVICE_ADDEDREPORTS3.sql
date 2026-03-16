CREATE function [dbo].[PR_DEVICE_ADDEDREPORTS3]( @DeviceID int, @DevCmpl datetime, @RevID int, @ModelID int, @MTID int)
returns nvarchar(max) WITH SCHEMABINDING
as
begin
   /*  вариант 3 используется в списке Incoming Shipment Request */
   
   declare @res nvarchar(max)
   set @res = ''

   select @res = @res + LTRIM(RTRIM(str(A.ID)))+';'
   from dbo.PR_REPORTS A with (nolock)
   where A.MTID = @MTID
     and A.S_S = 1000075 /* Approved */
     and A.USE_IN_ASSEMBLY = 1
     and isnull(A.USE_IN_ASSEMBLY,0) = 1
     and (     (A.USE_DEV_PROD = 1 and @DevCmpl is null)
            or (A.USE_DEV_READY = 1 and @DevCmpl is not null)
          )
     and dbo.PR_REPORT_USING2(A.ID,@ModelID,@RevID) = 1
       
   if LEN(@res) = 0
     return null
     
   return @res  

end;