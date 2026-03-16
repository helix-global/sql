-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2025-04-15
-- Description: Converts a string to an URI-encoded string.
-- =============================================
CREATE function [dbo].[URI_ENCODE](@InputString nvarchar(max))
returns nvarchar(max)
as
begin
  if @InputString is null return null
  declare @OutputString nvarchar(max)=N''
  select
    @OutputString=@OutputString+(
    case when [a].[VALUE]=ascii('!') then nchar([a].[VALUE])
         when [a].[VALUE]=ascii('(') then nchar([a].[VALUE])
         when [a].[VALUE]=ascii(')') then nchar([a].[VALUE])
         when [a].[VALUE]=ascii('*') then nchar([a].[VALUE])
         when [a].[VALUE]=ascii('-') then nchar([a].[VALUE])
         when [a].[VALUE]=ascii('.') then nchar([a].[VALUE])
         when [a].[VALUE]=ascii('_') then nchar([a].[VALUE])
         when [a].[VALUE]>=ascii('a') and [a].[VALUE]<=ascii('z') then nchar([a].[VALUE])
         when [a].[VALUE]>=ascii('A') and [a].[VALUE]<=ascii('Z') then nchar([a].[VALUE])
         when [a].[VALUE]>=ascii('0') and [a].[VALUE]<=ascii('9') then nchar([a].[VALUE])
    else '%'+format([a].[VALUE],'X2') end)
  from [dbo].[UCS_TO_UTF8_B](@InputString) [a]
  return @OutputString;
end