--#AZURE06081:2025-11-25: Initial Update.
CREATE procedure [trace].[SPTraceEnter]
  @ScopeName nvarchar(512),
  @ScopeGroup nvarchar(512) = null,
  @ScopeContext xml = null,
  @UseContextConnection bit  = 0,
  @Description nvarchar(max)=null
as
begin
  if exists(select *
            from sys.procedures [a]
            where [a].[name] = N'SPCLRTraceEnter'
              and SCHEMA_NAME([a].[schema_id])='trace'
              and [a].[type] in ('PC'))
  begin
    execute sp_executesql @stmt=N'
      execute [trace].[SPCLRTraceEnter]
        @UseContextConnection=@UseContextConnection,
        @ScopeGroup=@ScopeGroup,@ScopeName=@ScopeName,
        @Description=@Description,
        @ScopeContext=@ScopeContext',
      @params=N'
        @ScopeName nvarchar(512),
        @ScopeGroup nvarchar(512),
        @ScopeContext xml,
        @Description nvarchar(max),
        @UseContextConnection bit',
      @UseContextConnection=@UseContextConnection,
      @ScopeGroup=@ScopeGroup,@ScopeName=@ScopeName,
      @ScopeContext=@ScopeContext,
      @Description=@Description
  end
  return 0
end