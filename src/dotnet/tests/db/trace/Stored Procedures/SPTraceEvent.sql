--#AZURE06081:2025-11-25: Initial Update.
CREATE procedure [trace].[SPTraceEvent]
  @ScopeContext xml = null,
  @UseContextConnection bit = 0,
  @Message nvarchar(max),
  @LogLevel int = 0,
  @ErrorCode int = 0,
  @ScopeName nvarchar(max) = null
as
begin
  if exists(select *
            from sys.procedures [a]
            where [a].[name] = N'SPCLRTraceEvent'
              and SCHEMA_NAME([a].[schema_id])='trace'
              and [a].[type] in ('PC'))
  begin
    execute sp_executesql @stmt=N'
      execute [trace].[SPCLRTraceEvent]
        @UseContextConnection=@UseContextConnection,
        @Message=@Message,@LogLevel=@LogLevel,@ErrorCode=@ErrorCode,
        @Source=@Source,@ScopeContext=@ScopeContext',
      @params=N'
        @ScopeContext xml,@Message nvarchar(max),
        @LogLevel int,@ErrorCode int,
        @Source nvarchar(max),
        @UseContextConnection bit',
      @UseContextConnection=@UseContextConnection,
      @ScopeContext=@ScopeContext,
      @LogLevel=@LogLevel,@ErrorCode=@ErrorCode,
      @Message=@Message,
      @Source=@ScopeName
  end
  return 0
end