create FUNCTION [dbo].[SYNC_NOT_RESTRICTED](@SourceCode nvarchar(100),@RemoteCode nvarchar(100), @aMode int)
RETURNS int
AS
BEGIN
  
  /*KB3816*/
  /*@aMode
  1 - возвращает 1 если запрещено preparatory operations передавать в @RemoteCode
  2 - возвращает 1 если запрещено отчеты передавать в @RemoteCode
  */
  declare @flag int
  set @flag = 0
  
  if @aMode = 1
  begin
  
	select @flag = isnull(B.NO_PREPARATORY,0) 
	from COM_REMOTE A with(nolock)
	left join SYNC_RESTRICTIONS B with(nolock) on B.ID = A.ID
	where A.CODE = @RemoteCode
	
  
  end
  else if @aMode = 2
  begin

	select @flag = isnull(B.NO_REPORTS,0) 
	from COM_REMOTE A with(nolock)
	left join SYNC_RESTRICTIONS B with(nolock) on B.ID = A.ID
	where A.CODE = @RemoteCode
  
  
  end

  
  return isnull(@flag,0)

END