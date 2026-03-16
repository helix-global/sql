namespace BinaryStudio.SqlServer.Infrastructure
    {
    public interface ISqlAggregate
        {
        SqlObjectIdentifier QualifiedName { get; }
        }
    }