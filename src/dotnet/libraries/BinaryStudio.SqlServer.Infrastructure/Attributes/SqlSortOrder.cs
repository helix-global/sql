using System.ComponentModel;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [TypeConverter(typeof(SqlEnumConverter<SqlSortOrder>))]
    public enum SqlSortOrder
        {
        None,
        Ascending,
        Descending
        }
    }
