create function [dbo].[COM_STRING_BETWEEN](@aString nvarchar(max),@aStart nvarchar(max),@aEnd nvarchar(max),@aMode int)
returns nvarchar(max) as 
begin
  
  declare @res nvarchar(max) = null
  declare @posStart int
  declare @posEnd int
  
  set @posStart = charindex(@aStart,@aString)
  if @posStart > 0
  begin
	set @posEnd = charindex(@aEnd,@aString,@posStart)
	if @posEnd > @posStart
	  set @res = substring(@aString,@posStart,@posEnd-@posStart+len(@aEnd))
 
  end
  
  return @res

end