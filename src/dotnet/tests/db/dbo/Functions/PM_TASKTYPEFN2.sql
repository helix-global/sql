CREATE FUNCTION [dbo].[PM_TASKTYPEFN2](@OverrideType int, @ProjectType int,@ParentID int)
RETURNS nvarchar(200)
AS
BEGIN

/*KB2939*/
/*+KB3622*/

  declare @overide int = @OverrideType
  declare @pID int = @ParentID
  declare @i int = 0
  
  while @overide is null and @pID is not null
  begin
	
	select @overide = A.TASKTYPEOVERRIDE
	 ,@pID = A.PARENTID 
	 from PM_TASK A with(nolock)
	 where A.ID = @pID
	 
	set @i = @i + 1
	if @i > 50
	  break
  
  end

  if isnull(@overide,0) = 10
    return 'R&D Task'
    
  if isnull(@overide,0) = 20    
	return 'Sustaining Engineering'
  
  if isnull(@ProjectType,0) = 10 /*New Project*/
	return 'R&D Task'

  if isnull(@overide,@ProjectType) = 1000  /*KB3897 "При этом для проектов типа «Other» тип базовых задач «по умолчанию» должен быть так же «Other»."*/
	return 'Other'                         /*KB3897*/

  
  return 'Sustaining Engineering'

END