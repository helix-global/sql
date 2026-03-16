--#AZURE06081:2025-11-25: Initial Update.
CREATE procedure [trace].[SPTraceLeave]
  @ScopeContext xml = null,
  @ScopeName nvarchar(max) = null,
  @UseContextConnection bit = 0
as
begin
  if exists(select *
            from sys.procedures [a]
            where [a].[name] = N'SPCLRTraceLeave'
              and SCHEMA_NAME([a].[schema_id])='trace'
              and [a].[type] in ('PC'))
  begin
    execute sp_executesql @stmt=N'
      execute [trace].[SPCLRTraceLeave]
        @UseContextConnection=@UseContextConnection,
        @ScopeName=@ScopeName,
        @ScopeContext=@ScopeContext',
      @params=N'
        @ScopeContext xml,
        @ScopeName nvarchar(max),
        @UseContextConnection bit',
      @UseContextConnection=@UseContextConnection,
      @ScopeContext=@ScopeContext,
      @ScopeName=@ScopeName
  end
  return 0
end