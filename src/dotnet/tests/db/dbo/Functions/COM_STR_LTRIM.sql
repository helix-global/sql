-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-08-13
-- Description: Removes all the leading occurrences of a set of characters specified in an array from the current string.
-- =============================================
-- KB4717:2024-08-13: Initial update.
create function [dbo].[COM_STR_LTRIM](@Value nvarchar(max),@TrimCharacters nvarchar(max))
returns nvarchar(max) --with schemabinding
as
begin
  if @Value is null return null
  declare @TrimCharactersT table([CHAR] nvarchar(max))
  insert into @TrimCharactersT select [a].[OPTION] from [dbo].[COM_OPT_SPLIT](@TrimCharacters) [a]

  declare @PatternIndex int
  declare @Pattern nvarchar(max)

  while 1=1
  begin
    declare @Length int = len(@Value)
    if @Length=0 break
    set @PatternIndex = null
    select top 1
        @PatternIndex=charindex([a].[CHAR],@Value,1)
       ,@Pattern=[a].[CHAR]
    from @TrimCharactersT [a]
    where charindex([a].[CHAR],@Value,1)=1
    order by len([a].[CHAR]) desc

    if @PatternIndex is null break
    set @Value = right(@Value,@Length-len(@Pattern))
  end
  return @Value
end