namespace BinaryStudio.SqlServer.Infrastructure
    {
    public interface ISqlLiteralExpression
        {
        SqlLiteralValueType Type { get; }
        }
    }