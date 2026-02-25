using System.ComponentModel;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [TypeConverter(typeof(SqlEnumConverter<SqlAssemblyPermissionSet>))]
    public enum SqlAssemblyPermissionSet
        {
        Unknown,
        Safe,
        ExternalAccess,
        Unsafe
        }
    }
