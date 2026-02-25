using System.ComponentModel;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [TypeConverter(typeof(SqlEnumConverter<SqlQueryStoreCaptureMode>))]
    public enum SqlQueryStoreCaptureMode
        {
        All = 1,
        Auto,
        None
        }
    }
