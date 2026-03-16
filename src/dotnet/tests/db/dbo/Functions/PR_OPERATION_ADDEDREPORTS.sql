CREATE function [dbo].[PR_OPERATION_ADDEDREPORTS]( @OperID int, @OperState int, @OperTypeID int, @MTID int)
returns nvarchar(max) WITH SCHEMABINDING
as
begin
   /* 
      для того чтобы в будущем можно было добавлять пользовательские отчеты в список (из PR_REPORTS)
      не стал занимать диаппазон ID > 0
      а для worksheet сделал отрицательный признак "-2"
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
       
   if LEN(@res) = 0
     return null
     
   return @res  

end;