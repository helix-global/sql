using System.ComponentModel;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [TypeConverter(typeof(SqlEnumConverter<SqlQueryStoreOperationState>))]
    public enum SqlQueryStoreOperationState
        {
        Off,
        ReadOnly,
        ReadWrite
        }
    }
