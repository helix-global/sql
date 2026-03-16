CREATE function [dbo].[PR_SN](@snConst nvarchar(50),@snN int,@devid int)
returns nvarchar(50) as 
begin
  declare @res nvarchar(50) 
  declare @nstr nvarchar(50) 
  
  if @snConst = '-'
  begin
    set @res = 'SN not assigned (id:'+LTRIM(STR(@devid))+')';
    return @res;
  end
  
  if @snConst = '0'  
  begin
    set @res = LTRIM(STR(@snN));
    return @res;
  end
  
  set @nstr = CONVERT(nvarchar(50),@snN);
  set @nstr = REPLICATE('0',20) + @nstr;
  
  declare @i int
  set @i = LEN(@snConst);
  declare @one nvarchar(1);
  
  while @i > 0
  begin
    set @one = SUBSTRING(@snConst,@i,1)
    if @one = '#'
    begin
      set @one = SUBSTRING(@nstr,len(@nstr),1);
      set @nstr = SUBSTRING(@nstr,1,len(@nstr)-1);
    end
    
    set @res = @one + ISNULL(@res,'');
    
    set @i = @i - 1;
  end
  
  set @res = REPLACE(@res,'{O}','')
  set @res = REPLACE(@res,'{E}','')
  
  return @res;
end