namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal interface ISqlScriptTriggerDefinition
        {
        SqlIdentifier Name { get; }
        SqlObjectIdentifier TargetName { get; }
        }
    }