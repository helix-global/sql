-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-07-29
-- Description: Formats timespan
-- =============================================
-- Style:
--   00:HH:mm
--   01:HH:mm:ss
--   02:decimal value of hours (fixed point)
--   03:[H h][M m]
--   04:[Hh][Mm]
--   05:decimal value of hours (floating point)
--   06:HH:mm {N2 h}
CREATE function [dbo].[COM_STR_FORMAT_TIMESPAN](@Minutes float,@Style int)
returns nvarchar(max) with schemabinding
as
begin
  if @Minutes is null return null
  declare @HH int = abs(cast(@Minutes as int)/60)
  declare @MM int = abs(cast(@Minutes as int)%60)
  declare @SS int
  declare @Output nvarchar(max)
  declare @Sign   nvarchar(max) = N''

  if @Minutes<0 set @Sign=N'-'

  if @Style is null or @Style=0
  begin
    set @Output = @Sign+format(@HH,'D2')+N':'+format(@MM,'D2')
  end else
  if @Style=1
  begin
    set @Output = @Sign+format(@HH,'D2')+N':'+format(@MM,'D2')+N':00'
  end else
  if @Style=2
  begin
    set @Output = format(@Minutes/60.0,'N2')
  end else
  if @Style=3
  begin
         if @HH =  0 and @MM <> 0 set @Output = @Sign+cast(@MM as nvarchar(max))+N' m'
    else if @HH <> 0 and @MM  = 0 set @Output = @Sign+cast(@HH as nvarchar(max))+N' h'
    else set @Output = @Sign+cast(@HH as nvarchar(max))+N' h '+@Sign+cast(@MM as nvarchar(max)) + N' m'
  end else
  if @Style=4
  begin
         if @HH =  0 and @MM <> 0 set @Output = @Sign+cast(@MM as nvarchar(max))+N'm'
    else if @HH <> 0 and @MM  = 0 set @Output = @Sign+cast(@HH as nvarchar(max))+N'h'
    else set @Output = @Sign+cast(@HH as nvarchar(max))+N'h '+@Sign+cast(@MM as nvarchar(max)) + N'm'
  end else
  if @Style=5
  begin
    set @Output = format(@Minutes/60.0,'0.##')
  end else
  if @Style=6
  begin
    set @Output = @Sign+format(@HH,'D2')+N':'+format(@MM,'D2') + ' {' + format(@Minutes/60.0,'N2') + 'h}'
  end else
  begin
    set @Output = N'Invalid style parameter.'
  end
  return @Output
end