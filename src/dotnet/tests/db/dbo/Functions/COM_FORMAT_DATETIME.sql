CREATE function [dbo].[COM_FORMAT_DATETIME](@aValue datetime,@aMode int)
returns nvarchar(100) with schemabinding as 
begin
  declare @res nvarchar(100) 
  
  if @aMode = 1 /* dd.mm.yyyy hh:nn(если есть)  */
  begin
     
     set @res = convert(nvarchar,@aValue,104) 
     
     if datediff(minute,cast(@aValue as date),@aValue) > 0
       set @res = @res + ' '+ substring(convert(nvarchar,@aValue,108),1,5)
    
  end  
  else if @aMode = 2 /* mm.yyyy */
  begin
  
     set @res = convert(nvarchar,datepart(month,@aValue))
     if len(@res) = 1
       set @res = '0'+@res
      
     set @res = @res + '.' + convert(nvarchar,datepart(year,@aValue))
  
  end
  
  return @res;
end