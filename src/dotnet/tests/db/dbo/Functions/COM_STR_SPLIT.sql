-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-08-13
-- Description: Splits a string into substrings that are based on the provided string separator.
-- =============================================
-- KB4717:2024-08-13: Initial update.
create function [dbo].[COM_STR_SPLIT](@InputString nvarchar(max),@Separator nvarchar(max),@Options nvarchar(max))
returns
  @Output table ([ORDER] int,[VALUE] nvarchar(max))
--with schemabinding
as
begin
  if @InputString is null return
  if @Separator is null set @Separator=N'\,'

  declare @Order int = 0
  declare @OutputString nvarchar(max)
  declare @InputStringLength int = len(@InputString)
  declare @Values table([ORDER] int,[VALUE] nvarchar(max))
  declare @Char nvarchar(1)
  declare @I int, @PatternIndex int

  set @Options=rtrim(ltrim(@Options))
  if @Options=N'Options'
  begin
    insert into @Output
      select row_number() over (order by [a].[OPTION]),[a].[OPTION]
      from [dbo].[COM_OPT_SPLIT](@InputString) [a]
  end else
  begin
    declare @OptionsT table([OPTION] nvarchar(max))
    insert into @OptionsT
      select [a].[OPTION]
      from [dbo].[COM_OPT_SPLIT](@Options) [a]

    declare @SeparatorT table([SEPARATOR] nvarchar(max))
    insert into @SeparatorT
      select [a].[OPTION]
      from [dbo].[COM_OPT_SPLIT](@Separator) [a]

    declare @RemoveEmptyEntries int = 0
    declare @RemoveDuplicates   int = 0
    declare @TrimEntries        int = 0
    if exists(select [OPTION] from @OptionsT where [OPTION] like 'RemoveEmptyEntries') set @RemoveEmptyEntries=1
    if exists(select [OPTION] from @OptionsT where [OPTION] like 'RemoveDuplicates')   set @RemoveDuplicates=1
    if exists(select [OPTION] from @OptionsT where [OPTION] like 'TrimEntries')        set @TrimEntries=1

    declare @Substitute table([SUBST] nvarchar(max),[ORI] nvarchar(max))
    set @OutputString = N''
    set @I=1
    while @I <= @InputStringLength
    begin
      set @Char = right(left(@InputString,@I),1)
      set @I=@I+1
      if @Char='\'
      begin
        if @I <= @InputStringLength
        begin
          set @Char = right(left(@InputString,@I),1)
          if @Char='r' set @Char=nchar(13)
          if @Char='n' set @Char=nchar(10)
          if @Char='t' set @Char=nchar( 9)
          set @I=@I+1
          set @OutputString=@OutputString+N'#{'+format(unicode(@Char),N'x4') + N'}'
          insert into @Substitute([SUBST],[ORI]) values (N'#{'+format(unicode(@Char),N'x4')+N'}',@Char)
          continue
        end
      end
      set @OutputString=@OutputString+@Char
    end

    set @InputString=@OutputString
    set @InputStringLength=len(@InputString)
    set @I=1
    while @I <= @InputStringLength
    begin
      declare @CurrentSeparator nvarchar(max)
      set @PatternIndex = null
      select top 1
         @PatternIndex=charindex([a].[SEPARATOR],@InputString,@I)
        ,@CurrentSeparator=[a].[SEPARATOR]
      from @SeparatorT [a]
      where charindex([a].[SEPARATOR],@InputString,@I)<>0
      order by charindex([a].[SEPARATOR],@InputString,@I)
      if @PatternIndex is null break;

      set @OutputString = substring(@InputString,@I,@PatternIndex-@I)
      select @OutputString=replace(@OutputString,[a].[SUBST],[a].[ORI]) from @Substitute [a]
      if @TrimEntries=1 set @OutputString = ltrim(rtrim(@OutputString))
      set @I=@PatternIndex+len(@CurrentSeparator)
      if len(@OutputString)=0 and @RemoveEmptyEntries=1 continue
      if @RemoveDuplicates=0 or not exists(select [a].[ORDER] from @Values [a] where [a].[VALUE] like @OutputString)
      begin
        insert into @Values([ORDER],[VALUE]) values (@Order,@OutputString)
        set @Order=@Order+1
      end
    end
    if @I <= @InputStringLength
    begin
      set @OutputString = substring(@InputString,@I,@InputStringLength-@I+1)
      select @OutputString=replace(@OutputString,[a].[SUBST],[a].[ORI]) from @Substitute [a]
      if @TrimEntries=1 set @OutputString = ltrim(rtrim(@OutputString))
      if len(@OutputString)<>0 or @RemoveEmptyEntries=0
        if @RemoveDuplicates=0 or not exists(select [a].[ORDER] from @Values [a] where [a].[VALUE] like @OutputString)
        begin
          insert into @Values([ORDER],[VALUE]) values (@Order,@OutputString)
        end
    end else
    begin
      if @RemoveEmptyEntries=0
        if @RemoveDuplicates=0 or not exists(select [a].[ORDER] from @Values [a] where [a].[VALUE] like N'')
        begin
          insert into @Values([ORDER],[VALUE]) values (@Order,N'')
        end
    end
    insert into @Output
      select [a].[ORDER],[a].[VALUE]
      from @Values [a]
  end
  return
end