using System.ComponentModel;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [TypeConverter(typeof(SqlEnumConverter<SqlFormat>))]
    public enum SqlFormat
        {
        Unknown,
        Native,
        UserDefined
        }
    }