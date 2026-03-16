CREATE function [dbo].[PR_OPERATION_ADDEDREPORTS3]( @OperID int, @OperState int, @OperTypeID int, @DeviceID int, @DevCmpl datetime, @RevID int, @ModelID int, @MTID int, @EqID int, @EqModelID int)
returns nvarchar(max) 
as
begin

   declare @res nvarchar(max)
   set @res = ''

   declare @WorkSheetMode int 
   
   
   select @WorkSheetMode = isnull(A.WKS_MODE,0) from dbo.PR_OPERATIONS A with (nolock) where A.ID = @OperTypeID
   
   if @WorkSheetMode = 1
     set @res = '-2;'
   else if @WorkSheetMode = 2 and @OperState = 1000031 /*in progr*/
     set @res = '-2;'
   else if @WorkSheetMode = 3 and @OperState in (1000031,1000013) /*in progr, compl*/
     set @res = '-2;'
   else if @WorkSheetMode = 4 and @OperState = 1000013 /*compl*/
     set @res = '-2;'

   declare @tmp2 int = 2
   if @OperState = 1000013
      set @tmp2 = 1
   
   
   if @MTID is null and @EqID is not null  /*оборудование*/
   begin

       declare @EqMTID int
       
       select @EqMTID = B.MTID
       from EQ_MODELS A with (nolock)
       left join EQ_TYPES B with (nolock) on B.ID = A.EQTYPEID
       where A.ID = @EqModelID

	   select @res = @res + cast(A.ID as nvarchar)+';'
	   from dbo.PR_REPORTS A with (nolock)
	   where A.MTID = @EqMTID
		 and A.S_S = 1000075 /* Approved */
		 and A.USE_OPER_LIST = 1
		 and A.USE_DEV_PROD = 1 
		 and ( A.USE_OPER_ALL in (2,@tmp2) or A.USE_OPER_ONE = @OperTypeID )   
   
   
   end
   else
   begin
   
   
	   if @DevCmpl is null
	   begin
		   select @res = @res + cast(A.ID as nvarchar)+';'
		   from dbo.PR_REPORTS A with (nolock)
		   where A.MTID = @MTID
			 and A.S_S = 1000075 /* Approved */
			 and A.USE_OPER_LIST = 1
			 and A.USE_DEV_PROD = 1 
			 and ( A.USE_OPER_ALL in (2,@tmp2) or A.USE_OPER_ONE = @OperTypeID )   
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
			 and A.USE_OPER_LIST = 1
			 and A.USE_DEV_READY = 1 
			 and ( A.USE_OPER_ALL in (2,@tmp2) or A.USE_OPER_ONE = @OperTypeID )   
			 and ( A.FULLMT = 1
				   or exists (select B.ID from dbo.PR_REPORTS_T B with (nolock) where B.VNESHID = A.ID and B.REVID = @RevID and dbo.PR_REPORT_T_CHECKOPTIONS(@DeviceID,B.CUSTID,B.OPTIONID) = 1)
				   or exists (select B.ID from dbo.PR_REPORTS_T B with (nolock) where B.VNESHID = A.ID and B.MODELID = @ModelID and B.REVID is null and dbo.PR_REPORT_T_CHECKOPTIONS(@DeviceID,B.CUSTID,B.OPTIONID) = 1)
				  ) 
	   end
	
	
   end
   	   
   if LEN(@res) = 0
     return null
     
   return @res  

end;