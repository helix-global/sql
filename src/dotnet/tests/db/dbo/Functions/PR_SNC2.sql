CREATE function [dbo].[PR_SNC2](@aMask nvarchar(50) ,@dt datetime)
returns nvarchar(50) as 
begin
  /*для генерации по кнопке */
  declare @res nvarchar(50) 
  declare @aUpMask nvarchar(50)   
  
  set @aUpMask = UPPER(@aMask);

  if @aUpMask = '-'
    return '-'

  declare @yyyy nvarchar(4);
  declare @yy nvarchar(4);
  declare @mm nvarchar(2);
  declare @dd nvarchar(2);
  declare @ww nvarchar(2);
  declare @origin nvarchar(20)
  declare @origin2 nvarchar(20)
  
  select @origin = A.VALUESTR from DEF_SYSCONST A with (nolock) where A.LABEL = 'pr_origin' 
  set @origin = RTRIM(LTRIM(ISNULL(@origin,'0')))

  select @origin2 = A.VALUESTR from DEF_SYSCONST A with (nolock) where A.LABEL = 'pr_origin2' 
  set @origin2 = RTRIM(LTRIM(ISNULL(@origin2,'X')))


  set @yyyy = RTRIM(LTRIM(STR(YEAR(@dt))));
  set @yy = SUBSTRING(@yyyy,3,2);
  set @mm = RTRIM(LTRIM(STR(MONTH(@dt))));
  if LEN(@mm) = 1
    set @mm = '0' + @mm;
  set @dd = RTRIM(LTRIM(STR(DAY(@dt))));
  if LEN(@dd) = 1
    set @dd = '0' + @dd;
  
    
  set @res = @aMask;
  set @res = REPLACE(@res,'YYYY',@yyyy);
  set @res = REPLACE(@res,'YY',@yy);
  set @res = REPLACE(@res,'MM',@mm);
  set @res = REPLACE(@res,'DD',@dd);
  set @res = REPLACE(@res,'@',@origin);
  set @res = REPLACE(@res,'^',@origin2);
  
  set @res = REPLACE(@res,'\','');
  
  return @res
end