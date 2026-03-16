CREATE function [dbo].[PORTAL_FILE_INFO](@aFileDate datetime,@aFileSize int, @aMode int)
returns nvarchar(100) with schemabinding as 
begin
  
  declare @res nvarchar(100)
  
  if @aFileDate is not null
    set @res = convert(nvarchar,@aFileDate,104)+' ' +dbo.COM_HHMM(@aFileDate)
  
  declare @iGB int = 1024 * 1024 * 1024
  declare @iMB int = 1024 * 1024
  declare @iKB int = 1024
  
  declare @valF decimal(18,2) 
  set @valF = @aFileSize
  declare @sizeStr nvarchar(50)
  
  if (@aFileSize / @iGB) > 0
     set @sizeStr = cast(cast((@valF / @iGB) as decimal(10,2)) as nvarchar(50)) +' GB'
  else if (@aFileSize / @iMB) > 0
     set @sizeStr = cast(cast((@valF / @iMB) as decimal(10,2)) as nvarchar(50)) +' MB'
  else if (@aFileSize / @iKB) > 0
     set @sizeStr = cast(cast((@valF / @iKB) as decimal(10,2)) as nvarchar(50)) +' KB'
  else
     set @sizeStr = cast(@aFileSize as nvarchar(50)) + ' Byte(s)';
  
    
  return isnull(@res,'')+' '+isnull(@sizeStr,'')
  
end