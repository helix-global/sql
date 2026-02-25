using System.ComponentModel;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [TypeConverter(typeof(SqlEnumConverter<SqlDatabaseRecoveryMode>))]
    public enum SqlDatabaseRecoveryMode
        {
        Unknown,
        Simple,
        BulkLogged,
        Full
        }
    }
