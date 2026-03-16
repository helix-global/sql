CREATE procedure [dbo].[PRR_LABOR_UTILIZATION_JOB]
as 
BEGIN
set nocount on

declare @requestID int

select top 1 @requestID = A.ID from PRR_LU_REPORT_REQUEST A where A.S_S = 2130076 /*in queue*/ order by A.ID  

if @requestID is not null
begin

  exec PRR_LABOR_UTILIZATION_V6_CALC @requestID
  
end

set nocount off   
END