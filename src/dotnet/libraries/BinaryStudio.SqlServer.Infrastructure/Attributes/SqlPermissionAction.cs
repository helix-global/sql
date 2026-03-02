using System.ComponentModel;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [TypeConverter(typeof(SqlEnumConverter<SqlPermissionAction>))]
    public enum SqlPermissionAction
        {
        Grant,
        Deny
        }
    }
