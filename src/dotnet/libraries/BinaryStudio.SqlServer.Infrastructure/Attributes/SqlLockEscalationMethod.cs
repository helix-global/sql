using System.ComponentModel;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [TypeConverter(typeof(SqlEnumConverter<SqlLockEscalationMethod>))]
    public enum SqlLockEscalationMethod
        {
        Table,
        Disable,
        Auto
        }
    }
