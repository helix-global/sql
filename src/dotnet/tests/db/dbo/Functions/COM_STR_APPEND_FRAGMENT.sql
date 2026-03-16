-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-07-23
-- Description: Appends fragment string into target string.
-- =============================================
-- KB4891:2024-07-23: Initial update.
-- KB5106:2024-11-20: Optional parameter.
CREATE function [dbo].[COM_STR_APPEND_FRAGMENT](@TargetString nvarchar(max),@SourceString nvarchar(max),@PrefixString nvarchar(max),@Options nvarchar(max))
returns nvarchar(max) as
begin
  declare @AllowHtml int = 0
  declare @SourceColor nvarchar(max) = null
  declare @OptionsT table([OPTION] nvarchar(max))
  insert into @OptionsT
    select [a].[OPTION]
    from [dbo].[COM_OPT_SPLIT](@Options) [a]
  if exists(select * from @OptionsT [a] where [a].[OPTION] like N'AllowHtml')
  begin
    set @AllowHtml = 1
    if exists(select * from @OptionsT [a] where [a].[OPTION] like N'SourceColor=%')
    begin
      select top 1
        @SourceColor=right([o].[OPTION],len([o].[OPTION])-12)
      from @OptionsT [o] where [o].[OPTION] like N'SourceColor=%'
    end
  end
  if @SourceString is not null
  begin
    if @SourceColor is not null
    begin
      set @SourceString=N'<color='+@SourceColor+N'>'+@SourceString+N'</color>'
    end
  end

  if @SourceString is null or len(@SourceString)=0 return @TargetString
  if @TargetString is null or len(@TargetString)=0 return isnull(@PrefixString,N'')+@SourceString
  return @TargetString+nchar(13) + nchar(10)+isnull(@PrefixString,N'')+@SourceString
end