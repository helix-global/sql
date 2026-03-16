CREATE function [dbo].[LDM_CHARSN](@aLen int, @aNum int)
returns nvarchar(20) as 
begin

  declare @res nvarchar(20) 
  declare @one nvarchar(1) 
  declare @i int = @aNum
  declare @rest int = 0
  
  while @i > 0
  begin
    
    set @rest = @i % 25
    set @one = char(@rest + 65)
    set @i = @i / 25
    set @res = @one + isnull(@res,'')
    
  end
  
  while (len(isnull(@res,'')) < @aLen)
    set @res = 'A' + isnull(@res,'')
    
  return @res
end