CREATE procedure [dbo].[PRR_LABOR_UTILIZATION_V6_CALC](@RequestID int, @UserID int)
as 
BEGIN

   exec PRR_LABOR_UTILIZATION_V7_CALC @RequestID, @UserID 
    
END