-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-01-29
-- Description: Converts specified value to datetime type.
-- =============================================
-- KB4803:2024-05-21: Compatibility with 13.0.6435.1{IPGMD-CD-PDB02} SQL Server version.
-- KB4081:2024-01-29: Initial update.
CREATE function [dbo].[COM_CONVERT_TO_DT](@Value sql_variant)
returns datetime
as
begin
  if @Value is null return null
  declare @ValueBaseType sysname = cast(SQL_VARIANT_PROPERTY(@Value,'BaseType') as sysname)

  if @ValueBaseType = 'datetime' return cast(@Value as datetime)
  if @ValueBaseType = 'date'     return cast(@Value as date)
  if @ValueBaseType = 'time'     return cast(@Value as time)
  if @ValueBaseType = 'nvarchar'
  begin
    declare @ValueS varchar(max) = ltrim(rtrim(cast(@Value as varchar(max))))
    declare @ValueD datetime = null
    declare @ValueT time
    declare @ValueL int = len(@ValueS)
    declare @ValueM varchar(max)
    declare @ValueID int
    declare @ValueIM int
    declare @ValueIY int

    if @ValueL=6
    begin
      if (@ValueS like '[0-9][0-9][0-9][0-9][0-9][0-9]')
      begin
        set @ValueID = try_cast(substring(@ValueS,1,2) as int)
        set @ValueIM = try_cast(substring(@ValueS,3,2) as int)
        set @ValueIY = try_cast(substring(@ValueS,5,2) as int)
        if @ValueIM <= 12 and @ValueID <= 31 return convert(date,substring(@ValueS,5,2)+substring(@ValueS,3,2)+substring(@ValueS,1,2),12) -- ddMMyy
        if @ValueID <= 12 and @ValueIM <= 31 return convert(date,substring(@ValueS,5,2)+substring(@ValueS,1,2)+substring(@ValueS,3,2),12) -- MMddyy
        return convert(date,@ValueS,12) -- yyMMdd
      end
      if (@ValueD is null) and (@ValueS like '[0-9][0-9][1-3][0-9][0-9][0-9]') set @ValueD = convert(date,substring(@ValueS,5,2)+substring(@ValueS,1,4),12) -- MMddyy
      return @ValueD
    end else
    if @ValueL=7
    begin
      -- MM/yyyy
      if @ValueS like '[0-1][0-9]/[0-9][0-9][0-9][0-9]' set @ValueD = convert(date,'01/'+@ValueS,103)
      return @ValueD
    end else
    if @ValueL=8
    begin
      if (substring(@ValueS,3,1)='.') and (substring(@ValueS,6,1)='.')
      begin
        -- dd.MM.yy
        if try_cast(substring(@ValueS,4,2) as int) <= 12 return convert(date,@ValueS,4)
        return convert(date,substring(@ValueS,4,2)+'.'+substring(@ValueS,1,2)+'.'+substring(@ValueS,7,2),4) -- MM.dd.yy
      end
      if (substring(@ValueS,3,1)='/') and (substring(@ValueS,6,1)='/')
      begin
        -- dd/MM/yy
        if try_cast(substring(@ValueS,4,2) as int) <= 12 return convert(date,substring(@ValueS,7,2)+'/'+substring(@ValueS,4,2)+'/'+substring(@ValueS,1,2),3)
        return convert(date,substring(@ValueS,4,2)+'.'+substring(@ValueS,1,2)+'.'+substring(@ValueS,7,2),4) -- MM/dd/yy
      end
      -- MMM. yyyy
      if @ValueS like '___ [0-9][0-9][0-9][0-9]'
      begin
        set @ValueM = substring(@ValueS,1,3)
             if @ValueM='Mrz' or @ValueM='мар' set @ValueM='Mar'
        else if @ValueM='Mai' or @ValueM='май' set @ValueM='May'
        else if @ValueM='Okt' or @ValueM='окт' set @ValueM='Oct'
        else if @ValueM='Dez' or @ValueM='дек' set @ValueM='Dec'
        else if @ValueM='янв' set @ValueM='Jan'
        else if @ValueM='фев' set @ValueM='Feb'
        else if @ValueM='апр' set @ValueM='Apr'
        else if @ValueM='июн' set @ValueM='Jun'
        else if @ValueM='июл' set @ValueM='Jul'
        else if @ValueM='авг' set @ValueM='Aug'
        else if @ValueM='сен' set @ValueM='Sep'
        else if @ValueM='ноя' set @ValueM='Nov'
        set @ValueD = convert(datetime,
          '01 ' + @ValueM +
          substring(@ValueS,5,4),106)
        return @ValueD
      end
    end else
    if @ValueL=9
    begin
      -- dd.M.yyyy
      if (substring(@ValueS,3,1)='.') and (substring(@ValueS,5,1)='.')
      begin
        set @ValueD = convert(datetime,
          substring(@ValueS,1,2)+'.0' +
          substring(@ValueS,4,1) + '.' +
          substring(@ValueS,6,4),104)
        return @ValueD
      end
      -- MMM. yyyy
      if @ValueS like '___. [0-9][0-9][0-9][0-9]'
      begin
        set @ValueM = substring(@ValueS,1,3)
             if @ValueM='Mrz' or @ValueM='мар' set @ValueM='Mar'
        else if @ValueM='Mai' or @ValueM='май' set @ValueM='May'
        else if @ValueM='Okt' or @ValueM='окт' set @ValueM='Oct'
        else if @ValueM='Dez' or @ValueM='дек' set @ValueM='Dec'
        else if @ValueM='янв' set @ValueM='Jan'
        else if @ValueM='фев' set @ValueM='Feb'
        else if @ValueM='апр' set @ValueM='Apr'
        else if @ValueM='июн' set @ValueM='Jun'
        else if @ValueM='июл' set @ValueM='Jul'
        else if @ValueM='авг' set @ValueM='Aug'
        else if @ValueM='сен' set @ValueM='Sep'
        else if @ValueM='ноя' set @ValueM='Nov'
        set @ValueD = convert(datetime,
          '01 ' + @ValueM +
          substring(@ValueS,6,4),106)
        return @ValueD
      end
    end else
    if @ValueL=10
    begin
      if substring(@ValueS,3,1) = '.' and substring(@ValueS,6,1)='.'
      begin
        if try_cast(substring(@ValueS,4,2) as int) <= 12 return convert(datetime,@ValueS,104) -- dd.MM.yyyy
        else
        begin
          -- MM.dd.yyyy
          set @ValueD = convert(datetime,
            substring(@ValueS,4,2)+'.'+
            substring(@ValueS,1,2)+'.'+
            substring(@ValueS,7,4),104)
          return @ValueD
        end
      end else
      if substring(@ValueS,3,1) = '/' and substring(@ValueS,6,1)='/'
      begin
        if try_cast(substring(@ValueS,4,2) as int) <= 12 return convert(datetime,@ValueS,103) -- dd/MM/yyyy
        else
        begin
          -- MM/dd/yyyy
          set @ValueD = convert(datetime,
            substring(@ValueS,4,2)+'/'+
            substring(@ValueS,1,2)+'/'+
            substring(@ValueS,7,4),103)
          return @ValueD
        end
      end
    end else
    if @ValueL=11 -- dd-MMM yyyy
    begin
      set @ValueM = substring(@ValueS,4,3)
           if @ValueM='Mrz' or @ValueM='мар' set @ValueM='Mar'
      else if @ValueM='Mai' or @ValueM='май' set @ValueM='May'
      else if @ValueM='Okt' or @ValueM='окт' set @ValueM='Oct'
      else if @ValueM='Dez' or @ValueM='дек' set @ValueM='Dec'
      else if @ValueM='янв' set @ValueM='Jan'
      else if @ValueM='фев' set @ValueM='Feb'
      else if @ValueM='апр' set @ValueM='Apr'
      else if @ValueM='июн' set @ValueM='Jun'
      else if @ValueM='июл' set @ValueM='Jul'
      else if @ValueM='авг' set @ValueM='Aug'
      else if @ValueM='сен' set @ValueM='Sep'
      else if @ValueM='ноя' set @ValueM='Nov'
      set @ValueD = convert(datetime,substring(@ValueS,1,2) + ' ' + @ValueM + substring(@ValueS,8,4),106)
      return @ValueD
    end else
    if @ValueL=14
    begin
      -- dd.MM.yy hh:mm
      if @ValueS like '[0-3][0-9].[0-1][0-9].[0-9][0-9] [0-2][0-9]:[0-5][0-9]'
      begin
        return convert(datetime,'20'+
          substring(@ValueS, 7,2) + '-' +
          substring(@ValueS, 4,2) + '-' +
          substring(@ValueS, 1,2) + 'T' +
          substring(@ValueS,10,2) + ':' +
          substring(@ValueS,13,2) + ':00',126)
      end
    end else
    if @ValueL=18 -- dd.MM.yyyy h:mm:ss
    begin
      -- dd.MM.yyyy h:mm:ss
      if substring(@ValueS,11,1)=' '
      begin
        set @ValueD = convert(datetime,    substring(@ValueS, 1,10),104)
        set @ValueT = convert(datetime,'0'+substring(@ValueS,12, 7),108)
        return datetimefromparts(
          datepart(yy,@ValueD),datepart(mm,@ValueD),datepart(dd,@ValueD),
          datepart(hh,@ValueT),datepart(mi,@ValueT),datepart(ss,@ValueT),0)
      end
    end else
    if @ValueL=19 -- dd.MM.yyyy hh:mm:ss
    begin
      -- dd.MM.yyyy hh:mm:ss
      if substring(@ValueS,11,1)=' '
      begin
        set @ValueD = convert(datetime,substring(@ValueS, 1,10),104)
        set @ValueT = convert(datetime,substring(@ValueS,12, 8),108)
        return datetimefromparts(
          datepart(yy,@ValueD),datepart(mm,@ValueD),datepart(dd,@ValueD),
          datepart(hh,@ValueT),datepart(mi,@ValueT),datepart(ss,@ValueT),0)
      end
      if (@ValueS like '[1-9]/[1-9]/[0-9][0-9][0-9][0-9] [1-9]:[0-9][0-9]:[0-9][0-9] [AP]M') return parse(@ValueS as datetime using 'en-US')
    end else
    if @ValueL=20
    begin
      if (@ValueS like '[1-9]/[1-3][0-9]/[0-9][0-9][0-9][0-9] [1-9]:[0-9][0-9]:[0-9][0-9] [AP]M') return parse(@ValueS as datetime using 'en-US')
      if (@ValueS like '[1-9]/[1-9]/[0-9][0-9][0-9][0-9] 1[0-9]:[0-9][0-9]:[0-9][0-9] [AP]M')     return parse(@ValueS as datetime using 'en-US')
      if (@ValueS like '1[0-9]/[1-9]/[0-9][0-9][0-9][0-9] [1-9]:[0-9][0-9]:[0-9][0-9] [AP]M')     return parse(@ValueS as datetime using 'en-US')
      if (@ValueS like '[1-3][0-9]-___-[0-9][0-9] [1-9]:[0-5][0-9]:[0-5][0-9] [AP]M') -- dd-MMM-yy h:mm:ss tt
      begin
        return convert(datetime,
          substring(@ValueS,4,3)+' '+
          substring(@ValueS,1,2) + ' 20' +
          substring(@ValueS,8,2) + ' ' +
          substring(@ValueS,11,7)+':000'+
          substring(@ValueS,19,2),109)
      end
    end else
    if @ValueL=21
    begin
      -- dd-MMM-yy hh:mm:ss tt
      if @ValueS like '[0-3][0-9]-___-[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9] [AP]M'
      begin
        set @ValueM = substring(@ValueS,4,3)
             if @ValueM='Mrz' set @ValueM='Mar'
        else if @ValueM='Mai' set @ValueM='May'
        else if @ValueM='Okt' set @ValueM='Oct'
        else if @ValueM='Dez' set @ValueM='Dec'
        return convert(datetime,@ValueM+' '+
          substring(@ValueS, 1,2)+' 20'+
          substring(@ValueS, 8,2)+' '+
          substring(@ValueS,11,8)+':000'+
          substring(@ValueS,20,2),109)
      end
      if (@ValueS like '[1-9]/[1-3][0-9]/[0-9][0-9][0-9][0-9] 1[0-9]:[0-9][0-9]:[0-9][0-9] [AP]M') return parse(@ValueS as datetime using 'en-US')
      if (@ValueS like '1[0-9]/[1-9]/[0-9][0-9][0-9][0-9] 1[0-9]:[0-9][0-9]:[0-9][0-9] [AP]M')     return parse(@ValueS as datetime using 'en-US')
      if (@ValueS like '1[0-9]/[1-3][0-9]/[0-9][0-9][0-9][0-9] [1-9]:[0-9][0-9]:[0-9][0-9] [AP]M') return parse(@ValueS as datetime using 'en-US')
    end else
    if @ValueL=22
    begin
      if (@ValueS like '1[0-9]/[1-3][0-9]/[0-9][0-9][0-9][0-9] 1[0-9]:[0-9][0-9]:[0-9][0-9] [AP]M') return parse(@ValueS as datetime using 'en-US')
    end else
    if @ValueL=0 return null
    if @ValueS like '%, [1-9]. Januar [0-9][0-9][0-9][0-9]'
    begin
      set @ValueS = right(@ValueS,14)
      return convert(datetime,
        substring(@ValueS,11,4) + '-01-0' +
        substring(@ValueS, 1,1) + 'T00:00:00',126)
    end
    if @ValueS like '%, [1-9]. Februar [0-9][0-9][0-9][0-9]'
    begin
      set @ValueS = right(@ValueS,15)
      return convert(datetime,
        substring(@ValueS,12,4) + '-02-0' +
        substring(@ValueS, 1,1) + 'T00:00:00',126)
    end
    if @ValueS like '%, February [0-3][0-9], [0-9][0-9][0-9][0-9]'
    begin
      set @ValueS = right(@ValueS,17)
      return convert(datetime,
        substring(@ValueS,14,4) + '-02-' +
        substring(@ValueS,10,2) + 'T00:00:00',126)
    end
    if @ValueS like '%, May [0-3][0-9], [0-9][0-9][0-9][0-9]'
    begin
      set @ValueS = right(@ValueS,12)
      return convert(datetime,
        substring(@ValueS,9,4) + '-05-' +
        substring(@ValueS,5,2) + 'T00:00:00',126)
    end
    if @ValueS like '%, March [0-3][0-9], [0-9][0-9][0-9][0-9]'
    begin
      set @ValueS = right(@ValueS,14)
      return convert(datetime,
        substring(@ValueS,11,4) + '-03-' +
        substring(@ValueS, 7,2) + 'T00:00:00',126)
    end
    if @ValueS like '[0-1][0-9].[0-3][0-9].[0-9][0-9][0-9][0-9]-%'
    begin -- MM.dd.yyyy%
      return convert(datetime,
        substring(@ValueS,7,4) + '-' +
        substring(@ValueS,1,2) + '-' +
        substring(@ValueS,4,2) + 'T00:00:00',126)
    end
    if @ValueS like '%[0-1][0-9].[0-3][0-9].[0-9][0-9]'
    begin -- %MM.dd.yy
      set @ValueS = right(@ValueS,8)
      return convert(datetime,'20'+
        substring(@ValueS,7,2) + '-' +
        substring(@ValueS,1,2) + '-' +
        substring(@ValueS,4,2) + 'T00:00:00',126)
    end
  end
  return null
end