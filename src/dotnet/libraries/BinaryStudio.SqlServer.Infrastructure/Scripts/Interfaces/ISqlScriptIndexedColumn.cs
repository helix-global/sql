namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal interface ISqlScriptIndexedColumn
        {
        SqlSortOrder SortOrder { get; }
        SqlIdentifier Name { get; }
        }
    }
