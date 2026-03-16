CREATE function [dbo].[COM_LANG](@aCaption nvarchar(400),@aDefault nvarchar(400),@aUserID int)
returns nvarchar(400) as 
begin
  if @aCaption is null
    return @aDefault

  declare @lang int
  select @lang = convert(int,A.VALUE) from DEF_SETTINGS A with (nolock) where A.USERID = @aUserID and A.LABEL = 'def_language'

  declare @aLang nvarchar(10)
  select @aLang = NAME from DEF_ENUMERATION_T T with (nolock) where T.ENUMOID = 1000005 and T.CODE = @lang

  if @aLang is null
    return @aDefault

  set @aLang = '['+@aLang+'='

  declare @i int
  set @i = CHARINDEX(@aLang,@aCaption)
  if @i > 0
  begin  
     set @i = @i + LEN(@aLang)
     declare @res nvarchar(400)
     set @res = SUBSTRING(@aCaption,@i,999999)
     
     set @i = CHARINDEX('[',@res)
     if @i > 0 
     begin
       if (SUBSTRING(@res,@i+3,1) = '=') or (SUBSTRING(@res,@i+2,1) = '=')
         set @res = SUBSTRING(@res,1,@i-1)
     end
     
     return @res
  end
   
  return @aDefault 
  
end