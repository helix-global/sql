namespace BinaryStudio.SqlServer.Infrastructure
    {
    public interface ISqlAssembly
        {
        SqlIdentifier Name { get; }
        SqlObjectIdentifier QualifiedName { get; }
        }
    }