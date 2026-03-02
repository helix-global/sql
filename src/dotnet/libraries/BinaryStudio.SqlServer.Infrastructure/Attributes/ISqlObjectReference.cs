namespace BinaryStudio.SqlServer.Infrastructure
    {
    public interface ISqlObjectReference
        {
        SqlObjectIdentifier Reference { get; }
        }
    }