-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-12-03
-- Description: Formats system parameter.
-- =============================================
CREATE FUNCTION [dbo].[DEF_PRM_FMT](@object_id int,@parameter_id int,@options nvarchar(max))
returns nvarchar(max)
as
begin
  declare @Output nvarchar(max) = null
  declare @OptionsT table ([OPTION] nvarchar(max))
  insert into @OptionsT
    select [a].[OPTION]
    from [dbo].[COM_OPT_SPLIT](@options) [a]

  if exists (select * from @OptionsT [a] where [a].[OPTION]='ReturnParameter')
  begin
    select
      @Output = [b].[name] +
        case when [b].[name] in ('decimal','numeric') and ([a].[precision] <> 0 or [a].[scale] <> 0) then N'(' + cast([a].[precision] as nvarchar(max)) + N',' + cast([a].[scale] as nvarchar(max)) + N')'
             when [b].[name] in ('nvarchar','nchar','varchar','char','varbinary','binary') and [a].[max_length] =-1 then N'(max)'
             when [b].[name] in ('nvarchar','nchar') and [a].[max_length]<>-1 then N'(' + cast([a].[max_length]/2 as nvarchar(max)) + N')'
             when [b].[name] in ('varchar','char','varbinary','binary') and [a].[max_length]<>-1 then N'(' + cast([a].[max_length] as nvarchar(max)) + N')'
             when [b].[name] in ('datetime2','time2','datetimeoffset') then N'(' + cast([a].[scale] as nvarchar(max)) + N')'
        else N''
        end
    from sys.parameters [a] with(nolock)
      inner join sys.types [b] with(nolock) on [b].[user_type_id]=[a].[user_type_id]
    where [a].[object_id]=@object_id
      and [a].[parameter_id]=@parameter_id
  end else
  begin
    select
      @Output = [a].[name] + N' ' + [b].[name] +
        case when [b].[name] in ('decimal','numeric') and ([a].[precision] <> 0 or [a].[scale] <> 0) then N'(' + cast([a].[precision] as nvarchar(max)) + N',' + cast([a].[scale] as nvarchar(max)) + N')'
             when [b].[name] in ('nvarchar','nchar','varchar','char','varbinary','binary') and [a].[max_length] =-1 then N'(max)'
             when [b].[name] in ('nvarchar','nchar') and [a].[max_length]<>-1 then N'(' + cast([a].[max_length]/2 as nvarchar(max)) + N')'
             when [b].[name] in ('varchar','char','varbinary','binary') and [a].[max_length]<>-1 then N'(' + cast([a].[max_length] as nvarchar(max)) + N')'
             when [b].[name] in ('datetime2','time2','datetimeoffset') then N'(' + cast([a].[scale] as nvarchar(max)) + N')'
        else N''
        end
    from sys.parameters [a] with(nolock)
      inner join sys.types [b] with(nolock) on [b].[user_type_id]=[a].[user_type_id]
    where [a].[object_id]=@object_id
      and [a].[parameter_id]=@parameter_id
  end
  return @Output
end