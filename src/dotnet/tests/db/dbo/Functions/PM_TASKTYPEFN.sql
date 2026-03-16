create FUNCTION [dbo].[PM_TASKTYPEFN](@OverrideType int, @ProjectType int)
RETURNS nvarchar(200)
AS
BEGIN

/*KB2939*/

  if isnull(@OverrideType,0) = 10
    return 'R&D Task'
    
  if isnull(@OverrideType,0) = 20    
	return 'Sustaining Engineering'
  
  if isnull(@ProjectType,0) = 10 /*New Project*/
	return 'R&D Task'
  
  return 'Sustaining Engineering'

END