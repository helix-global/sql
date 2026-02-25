using System.ComponentModel;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [TypeConverter(typeof(SqlEnumConverter<SqlTriggerType>))]
    public enum SqlTriggerType
        {
        Unknown,
        For,
        After,
        InsteadOf
        }
    }