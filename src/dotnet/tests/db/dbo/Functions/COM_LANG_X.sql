CREATE function [dbo].[COM_LANG_X](@aCaption nvarchar(max),@aLangCode nvarchar(2))
returns nvarchar(max) as 
begin
  if @aCaption is null
    return null

  declare @res nvarchar(max)
  declare @aLang nvarchar(10)
  set @aLang = '['+upper(@aLangCode)+'='

  declare @i int
  set @i = CHARINDEX(@aLang,@aCaption)
  if @i > 0
  begin  
     set @i = @i + LEN(@aLang)
     set @res = SUBSTRING(@aCaption,@i,999999)
     
     set @i = CHARINDEX('[',@res)
     if @i > 0 
     begin
       if (SUBSTRING(@res,@i+3,1) = '=') or (SUBSTRING(@res,@i+2,1) = '=')
         set @res = SUBSTRING(@res,1,@i-1)
     end
     
     return @res
  end
  else
  begin
     set @aLang = '[L='
     set @i = CHARINDEX(@aLang,@aCaption)
     if @i > -1
     begin
        
        declare @label nvarchar(50)
        set @i = @i + LEN(@aLang)
        set @label = SUBSTRING(@aCaption,@i,999999)
        set @i = CHARINDEX('[',@label)
        if @i > 0 
          set @label = SUBSTRING(@label,1,@i-1)
        
        declare @lang int
        select @lang = A.CODE
        from DEF_ENUMERATION_T A with (nolock)
        where A.ENUMOID = 1000005
          and NAME = upper(@aLangCode)
        
        if @lang is not null
        begin
        
			declare @fromDict nvarchar(600) = null
			select top 1 @fromDict = A.CAPTION 
			from DEF_DICTIONARY_T A with (nolock)
			left join DEF_DICTIONARY B with (nolock) on B.OID = A.DICTOID
			where A.LABEL = @label
			  and B.LANGUAGE = @lang
	        
			if @fromDict is not null
			  return @fromDict 
          
        end
        
     end
  end
  
  set @res = @aCaption  
  set @i = 0
  set @i = CHARINDEX('[',@res)
  if @i > 0 
  begin
    if (SUBSTRING(@res,@i+3,1) = '=') or (SUBSTRING(@res,@i+2,1) = '=')
      set @res = SUBSTRING(@res,1,@i-1)
  end  
   
  return @res
  
end