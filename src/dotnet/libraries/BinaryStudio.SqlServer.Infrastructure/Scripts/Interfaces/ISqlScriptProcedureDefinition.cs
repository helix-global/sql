namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal interface ISqlScriptProcedureDefinition
        {
        SqlObjectIdentifier Name { get; }
        }
    }