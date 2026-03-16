CREATE function [dbo].[COM_FORMAT_DHM](@aValue decimal(12,2),@aMode int)
returns nvarchar(100) with schemabinding as 
begin
  if @aValue is null and @aMode = 1
    return 'NA'

  if @aValue is null
    return null
    
  if @aValue = 0
    return '0'

  declare @res nvarchar(100)
  set @res = ''
  
  declare @days int
  declare @hours int
  declare @minutes int
  declare @seconds int
  
  set @days = @aValue / 24 / 60;
  
  if @days > 0
    set @res = LTRIM(RTRIM(STR(@days)))+'d';
    
  set @hours = (@aValue - @days * 24 * 60) / 60;
  if @hours > 0
    set @res = @res + ' '+LTRIM(RTRIM(STR(@hours)))+'h';
  
  set @minutes = @aValue - @days * 24 * 60 - @hours * 60;
  if @minutes > 0
     set @res = @res + ' '+LTRIM(RTRIM(STR(@minutes)))+'m';
  
  set @seconds = (@aValue - ROUND(@aValue,0,1)) * 60
  if @seconds > 0
     set @res = @res + ' '+LTRIM(RTRIM(STR(@seconds)))+'s';
  
  
  return ltrim(rtrim(@res));
end