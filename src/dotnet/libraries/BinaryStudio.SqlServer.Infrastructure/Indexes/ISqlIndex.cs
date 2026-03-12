namespace BinaryStudio.SqlServer.Infrastructure
    {
    public interface ISqlIndex
        {
        SqlObjectIdentifier QualifiedName { get; }
        SqlIdentifier Name { get; }
        }
    }