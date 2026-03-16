CREATE procedure [dbo].PR_IMP_CMP_AND_DELETE_DUPL_VALUE  @RowID int
as 
set nocount on

declare @currentValue sql_variant
declare @PrevRecordID int = null

select @currentValue = A.PVALUE
      ,@PrevRecordID = (select top 1 G.ID from PR_DEVICE_IN_VALUES G with(nolock) where G.DEVICEID = A.DEVICEID and G.PARAMID = A.PARAMID and G.ID < A.ID order by G.ID desc)
from PR_DEVICE_IN_VALUES A with (nolock)
where A.ID = @RowID

if @PrevRecordID is null
begin
   --print 'no previous records found'
   set nocount off
   return
end

declare @previousValue sql_variant

select @previousValue = B.PVALUE from PR_DEVICE_IN_VALUES B with (nolock) where B.ID = @PrevRecordID

if @previousValue = @currentValue
begin

  delete from PR_DEVICE_IN_VALUES where ID = @RowID
  --print @PrevRecordID
  
end

set nocount off