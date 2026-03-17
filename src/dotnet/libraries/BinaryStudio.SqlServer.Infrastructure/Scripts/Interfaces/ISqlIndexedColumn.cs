namespace BinaryStudio.SqlServer.Infrastructure
    {
    public interface ISqlIndexedColumn
        {
        SqlSortOrder SortOrder { get; }
        SqlIdentifier Name { get; }
        }
    }
