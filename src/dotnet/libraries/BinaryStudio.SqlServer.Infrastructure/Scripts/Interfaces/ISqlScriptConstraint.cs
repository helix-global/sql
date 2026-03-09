namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal interface ISqlScriptConstraint
        {
        SqlIdentifier Name { get; }
        SqlConstraintType Type { get; }
        }
    }