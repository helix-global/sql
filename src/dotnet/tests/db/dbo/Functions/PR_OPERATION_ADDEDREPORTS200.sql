CREATE function [dbo].[PR_OPERATION_ADDEDREPORTS200]( @OperID int, @OperState int, @OperTypeID int, @DeviceID int, @DevCmpl datetime, @RevID int, @ModelID int, @MTID int)
returns nvarchar(max) WITH SCHEMABINDING
as
begin
   /* 
      15.03.16 добавлены пользовательские отчеты
   */

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
   
   select @res = @res + cast(A.ID as nvarchar)+';'
   from dbo.PR_REPORTS A with (nolock)
   where A.MTID = @MTID
     and A.S_S = 1000075 /* Approved */
     and A.USE_OPER_LIST = 1
     and (     (A.USE_DEV_PROD = 1 and @DevCmpl is null)
            or (A.USE_DEV_READY = 1 and @DevCmpl is not null)
          )
     and (     (A.USE_OPER_ALL = 1 and  @OperState = 1000013)
            or (A.USE_OPER_ALL = 2)
            or (A.USE_OPER_ONE = @OperTypeID)
          )   
     and ( A.FULLMT = 1
           or exists (select B.ID from dbo.PR_REPORTS_T B with (nolock) where B.VNESHID = A.ID and B.REVID = @RevID)
           or exists (select B.ID from dbo.PR_REPORTS_T B with (nolock) where B.VNESHID = A.ID and B.MODELID = @ModelID and B.REVID is null)
          ) 

       
   if LEN(@res) = 0
     return null
     
   return @res  

end;