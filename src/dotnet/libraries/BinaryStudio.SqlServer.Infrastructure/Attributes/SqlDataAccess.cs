using System.ComponentModel;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [TypeConverter(typeof(SqlEnumConverter<SqlDataAccess>))]
    public enum SqlDataAccess
        {
        None,
        Read
        }
    }