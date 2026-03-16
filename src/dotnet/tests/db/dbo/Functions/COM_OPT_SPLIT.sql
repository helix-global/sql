-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-08-13
-- Description: Splits a "option" string into substrings that are based on the default string separator.
-- =============================================
-- KB5029:2024-10-28: Added special processing for nested groups {}.
-- KB4717:2024-08-13: Initial update.
CREATE function [dbo].[COM_OPT_SPLIT](@InputString nvarchar(max))
returns
  @Output table ([OPTION] nvarchar(max))
as
begin
  if @InputString is null return

  declare @OutputString nvarchar(max)
  declare @InputStringLength int = len(@InputString)
  declare @Values table([VALUE] nvarchar(max))
  declare @Char nvarchar(1)
  declare @I int
  declare @InGroup int = 0

  set @OutputString=N''
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
        if @Char='{' set @Char='{'
        set @I=@I+1
        set @OutputString=@OutputString+@Char
      end
    end else
    if @Char=N'{'
    begin
      set @InGroup = @InGroup + 1
      if @InGroup > 1
        set @OutputString=@OutputString+@Char
    end else
    if @InGroup>0
    begin
      if @Char=N'}'
      begin
        set @InGroup = @InGroup-1
        if @InGroup<0 set @InGroup=0
        if @InGroup>0
          set @OutputString=@OutputString+@Char
      end else
        set @OutputString=@OutputString+@Char
    end else
    if @Char=N',' or @Char=N';'
    begin
      set @OutputString=ltrim(rtrim(@OutputString))
      if len(@OutputString)=0 continue;
      insert into @Values([VALUE]) values (@OutputString)
      set @OutputString=N''
    end else
    begin
      set @OutputString=@OutputString+@Char
    end
  end
  if @OutputString<>N''
  begin
    insert into @Values([VALUE]) values (@OutputString)
  end
  insert into @Output
    select distinct [a].[VALUE]
    from @Values [a]
  return
end