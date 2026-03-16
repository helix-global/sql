-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2025-02-14
-- Description: Converts specified value to datetime type.
-- =============================================
-- KB5247: 2025-02-14: Initial Update.
-- KB5186: 2025-04-03: "d.HH:mm:ss" pattern.
CREATE FUNCTION [dbo].[COM_TIME_PARSE](@Value sql_variant)
returns datetime2
as
begin
  if @Value is null return null
  declare @ValueBaseType sysname = cast(SQL_VARIANT_PROPERTY(@Value,'BaseType') as sysname)
  if @ValueBaseType = 'datetime' return cast(@Value as datetime)
  if @ValueBaseType = 'date'     return cast(@Value as date)
  if @ValueBaseType = 'time'     return cast(@Value as time)
  if @ValueBaseType = 'nvarchar' or @ValueBaseType = 'varchar'
  begin
    declare @RetVal datetime2
    declare @ValueS varchar(max) = ltrim(rtrim(cast(@Value as varchar(max))))
    declare @ValueIH int
    declare @ValueIM int
    declare @ValueIS int
    declare @ValueID int

    -- HH:mm:ss
    if (@ValueS like '[0-2][0-9]:[0-5][0-9]:[0-5][0-9]')
    begin
      set @ValueIH = try_cast(substring(@ValueS,1,2) as int)
      set @ValueIM = try_cast(substring(@ValueS,4,2) as int)
      set @ValueIS = try_cast(substring(@ValueS,7,2) as int)
      if @ValueIH < 24
      begin
        return convert(time,substring(@ValueS,1,2)+':'+substring(@ValueS,4,2)+':'+substring(@ValueS,7,2),24)
      end
    end
    -- d.HH:mm:ss
    if (@ValueS like '[0-9][.][0-2][0-9]:[0-5][0-9]:[0-5][0-9]')
    begin
      set @ValueID = try_cast(substring(@ValueS,1,1) as int)
      set @ValueIH = try_cast(substring(@ValueS,3,2) as int)
      set @ValueIM = try_cast(substring(@ValueS,6,2) as int)
      set @ValueIS = try_cast(substring(@ValueS,9,2) as int)
      if @ValueIH < 24
      begin
        set @RetVal=convert(time,substring(@ValueS,3,2)+':'+substring(@ValueS,6,2)+':'+substring(@ValueS,9,2),24)
        if @ValueID > 0
        begin
          set @RetVal=dateadd(dd,@ValueID,@RetVal)
        end
        return @RetVal
      end
    end
  end
  return null
end