CREATE function [dbo].[PR_RMA_CUT_LASTPART](@aNN nvarchar(20),@aMode int)
returns nvarchar(20) with schemabinding as  
begin
  declare @res nvarchar(20) = @aNN
  
  if upper(@aNN) like 'RMA%.%'
  begin
     
     declare @rev nvarchar(20) = reverse(@aNN)
     declare @i int = charindex('.',@rev)
     if @i > 0
     begin
        set @rev = substring(@rev,@i+1,99)
        set @res = reverse(@rev)
     end
     
  end

  return @res
end