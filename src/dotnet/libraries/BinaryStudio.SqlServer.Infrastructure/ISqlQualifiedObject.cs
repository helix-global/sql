namespace BinaryStudio.SqlServer.Infrastructure
    {
    public interface ISqlQualifiedObject
        {
        SqlObjectIdentifier QualifiedName { get; }
        }
    }