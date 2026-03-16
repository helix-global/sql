CREATE function dbo.COM_STRING_CONTAINS(@aString nvarchar(max),@aParts nvarchar(max),@aMode int)
returns int as 
begin
/*
   @aMode 1 - все части из @aParts есть в @aString
   @aMode 2 - одна из частей @aParts есть в @aString
*/
  if @aString is null or @aParts is null return 0
  
  declare @aString2 nvarchar(max)
  declare @aParts2 nvarchar(max)
  
  set @aString2 = REPLACE(@aString,';',',')
  set @aParts2 = REPLACE(@aParts,';',',')
  
  if CHARINDEX(',',@aParts2) = 0 
  begin
    /* один аргумент */
    if CHARINDEX(','+@aParts2+',',','+@aString2+',') = 0
      return 0
    else
      return 1
  end

  /* несколько аргументов */
  
  declare @i int
  declare @somethingpassed int
  set @somethingpassed = 0
  declare @onePart nvarchar(max)
  set @aParts2 = @aParts2 + ','
  set @i = CHARINDEX(',',@aParts2)
  while (@i > 0)
  begin
    set @onePart = SUBSTRING(@aParts2,0,@i);
  
    if LEN(@onePart) > 0
    begin
       if @aMode = 2 and CHARINDEX(','+@onePart+',',','+@aString2+',') > 0
         return 1
       
       if @aMode = 1 and CHARINDEX(','+@onePart+',',','+@aString2+',') = 0
         return 0
       else
         set @somethingpassed = 1
         
       
    end
  
    set @aParts2 = SUBSTRING(@aParts2,@i+1,999999)
    set @i = CHARINDEX(',',@aParts2)
  end
  
  if @aMode = 1 and LEN(@aParts) > 0 and LEN(@aString) > 0 and @somethingpassed = 1
     return 1
  
  return 0

end