CREATE function [dbo].[PR_DEVICE_ADDEDREPORTS5]( @DeviceID int, @DevCmpl datetime, @RevID int, @ModelID int, @MTID int, @UserDepID int)
returns nvarchar(max) 
as
begin

/*
29.04.2020 KB1457 
создана из PR_DEVICE_ADDEDREPORTS 
добавлена проверка, если в отчете USE_IN_ASSEMBLY != 1 то проверяется 
что пользователь из подразделения = подразделению шаблона или ниже по ОШС   
*/

    declare @res nvarchar(max)
    set @res = ''

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
		 and ( A.USE_IN_ASSEMBLY = 1
		       or dbo.COM_IS_SAME_OR_CHILD_DEPARTMENT(@UserDepID,A.DEPID) = 1
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
   	     and ( A.USE_IN_ASSEMBLY = 1
		       or dbo.COM_IS_SAME_OR_CHILD_DEPARTMENT(@UserDepID,A.DEPID) = 1
		     ) 

	end     
	   
    if LEN(@res) = 0
      return null
     
    return @res  

end;