using System.ComponentModel;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [TypeConverter(typeof(SqlEnumConverter<SqlSystemDataAccess>))]
    public enum SqlSystemDataAccess
        {
        None,
        Read
        }
    }