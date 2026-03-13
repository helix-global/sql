namespace BinaryStudio.SqlServer.Infrastructure
    {
    public interface ISqlProcedure
        {
        SqlObjectIdentifier Name { get; }
        }
    }