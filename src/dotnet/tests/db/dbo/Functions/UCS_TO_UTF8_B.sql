-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2025-04-15
-- Description: Converts a string to an UTF-8 byte array.
-- =============================================
CREATE function [dbo].[UCS_TO_UTF8_B](@source nvarchar(max))
returns @target table([VALUE] tinyint)
begin
  declare @i int = 1
  declare @l int = len(@source)
  while @i <= @l
  begin
    declare @unicode int = unicode(right(left(@source,@i),1))
    if @unicode <= 127
    begin
      insert into @target([VALUE]) values (@unicode)
    end else
    if @unicode <= 2047
    begin
      insert into @target([VALUE]) values ((@unicode&1984)/64 + 192)
      insert into @target([VALUE]) values ((@unicode&63) + 128)
    end else
    if @unicode <= 65535
    begin
      insert into @target([VALUE]) values ((@unicode&61440)/4096 + 224)
      insert into @target([VALUE]) values ((@unicode&4032)/64 + 128)
      insert into @target([VALUE]) values ((@unicode&63) + 128)
    end else
    begin
      insert into @target([VALUE]) values ((@unicode&1835008)/262144 + 240)
      insert into @target([VALUE]) values ((@unicode&258048)/4096 + 128)
      insert into @target([VALUE]) values ((@unicode&4032)/64 + 128)
      insert into @target([VALUE]) values ((@unicode&63) + 128)
    end
    set @i=@i+1
  end
  return
end