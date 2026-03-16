CREATE function [dbo].[PR_OPERATION_ADDEDREPORTS_20]( @OperState int, @OperTypeID int, @DevCmpl datetime, @RevID int)
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
   
   select @res = @res + LTRIM(RTRIM(str(A.ID)))+';'
   from dbo.PR_REPORTS A with (nolock)
   where A.ID in (select BB.REPORTID from PR_REPORTS_REVISIONS BB with (nolock) where BB.REVID = @RevID)
     and A.S_S = 1000075 /* Approved */
     and A.USE_OPER_LIST = 1
     and (     (A.USE_DEV_PROD = 1 and @DevCmpl is null)
            or (A.USE_DEV_READY = 1 and @DevCmpl is not null)
          )
     and (     (A.USE_OPER_ALL = 1 and  @OperState = 1000013)
            or (A.USE_OPER_ALL = 2)
            or (A.USE_OPER_ONE = @OperTypeID)
          )   
	   
   if LEN(@res) = 0
     return null
     
   return @res  

end;