CREATE function [dbo].[MSG_FC_REPORT_SUBJ](@aFarID int)
returns nvarchar(300) 
as
begin

   declare @sFRnumb nvarchar(300)
   declare @sFRnumb2 nvarchar(300)

	select @sFRnumb = 'FR-'+isnull(C.CODE,'NA')+'-'+ltrim(rtrim(isnull(str(A.ID),'NA')))
	      ,@sFRnumb2 = dbo.FC_REPORT_NUMBER(A.RMA_TYPE,A.RMA)
	from FC_REPORT A 
	left join PR_MODELS B on B.ID = A.MODELID
	left join COM_DEPARTMENTS C on C.ID = B.DEPID
	where A.ID = @aFarID
	
	if len(@sFRnumb2) > 0
	  set @sFRnumb = @sFRnumb+', '+@sFRnumb2
    
  return @sFRnumb
end;