CREATE procedure [dbo].[FC_CHECK_DOUBLE] 
 @FRID int, @mode int
as 
SET nocount on

declare @dblID int
declare @sn nvarchar(50)
declare @code nvarchar(50)
declare @rma nvarchar(50)

select top 1 @dblID = B.ID
        ,@sn = B.SN
        ,@code = C.CODE 
        ,@rma = B.RMA
from FC_REPORT A with (nolock)
left join FC_REPORT B with (nolock) on B.MODELID = A.MODELID and B.SN = A.SN and B.RMA = A.RMA and B.INT_EXT = A.INT_EXT and B.EXTPARENTID is null /*KB836*/
left join PR_MODELS C with (nolock) on C.ID = B.MODELID
where A.ID = @FRID
  and A.RMA is not null
  and A.INT_EXT = 2 /* 16.03.18 only checks "in field" */
  and A.ID <> B.ID
  

if @dblID is not null
begin

   declare @mess nvarchar(max)
   set @mess = '#EFailure report for item '+isnull(@sn,'NA')+' (PN: '+isnull(@code,'NA')+') with service number '+isnull(@rma,'NA')+' already exists (Failure Report ID: '+ltrim(rtrim(str(@dblID)))+')'
   raiserror(@mess,16,1)
   

end

SET nocount off