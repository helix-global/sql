CREATE function [dbo].[COM_BYTES](@aBytes bigint)
returns nvarchar(max) with schemabinding as 
begin
 
    declare @value bigint = @aBytes
    
    if @value < 1024
      return ltrim(rtrim(str(@value)))+' B'
      
    set @value = @value / 1024
    if @value < 1024
      return ltrim(rtrim(str(@value)))+' KB'

    set @value = @value / 1024
    if @value < 1024
      return ltrim(rtrim(str(@value)))+' MB'
      
    set @value = @value / 1024
    return ltrim(rtrim(str(@value)))+' GB'


end