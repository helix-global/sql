CREATE function [dbo].[PR_DEVICE_ADDEDREPORTS]( @DeviceID int, @DevCmpl datetime, @RevID int, @ModelID int, @MTID int)
returns nvarchar(max) 
as
begin

    declare @res nvarchar(max)
    set @res = ''

/*
   select @res = @res + LTRIM(RTRIM(str(A.ID)))+';'
   from dbo.PR_REPORTS A with (nolock)
   where A.MTID = @MTID
     and A.S_S = 1000075 /* Approved */
     and A.USE_DEV_LIST = 1
     and (     (A.USE_DEV_PROD = 1 and @DevCmpl is null)
            or (A.USE_DEV_READY = 1 and @DevCmpl is not null)
          )
     and dbo.PR_REPORT_USING2(A.ID,@ModelID,@RevID) = 1
*/
	if @DevCmpl is null
	begin
	   select @res = @res + cast(A.ID as nvarchar)+';'
	   from dbo.PR_REPORTS A with (nolock)
	   where A.MTID = @MTID
		 and A.S_S = 1000075 /* Approved */
		 and A.USE_DEV_LIST = 1
		 and A.USE_DEV_PROD = 1 
		 and ( A.FULLMT = 1
			   or exists (select B.ID from dbo.PR_REPORTS_T B with (nolock) where B.VNESHID = A.ID and B.REVID = @RevID and dbo.PR_REPORT_T_CHECKOPTIONS(@DeviceID,B.CUSTID,B.OPTIONID) = 1)
			   or exists (select B.ID from dbo.PR_REPORTS_T B with (nolock) where B.VNESHID = A.ID and B.MODELID = @ModelID and B.REVID is null and dbo.PR_REPORT_T_CHECKOPTIONS(@DeviceID,B.CUSTID,B.OPTIONID) = 1)
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
		 and ( A.FULLMT = 1
			   or exists (select B.ID from dbo.PR_REPORTS_T B with (nolock) where B.VNESHID = A.ID and B.REVID = @RevID and dbo.PR_REPORT_T_CHECKOPTIONS(@DeviceID,B.CUSTID,B.OPTIONID) = 1)
			   or exists (select B.ID from dbo.PR_REPORTS_T B with (nolock) where B.VNESHID = A.ID and B.MODELID = @ModelID and B.REVID is null and dbo.PR_REPORT_T_CHECKOPTIONS(@DeviceID,B.CUSTID,B.OPTIONID) = 1)
			  ) 
	end     
	   
    if LEN(@res) = 0
      return null
     
    return @res  

end;