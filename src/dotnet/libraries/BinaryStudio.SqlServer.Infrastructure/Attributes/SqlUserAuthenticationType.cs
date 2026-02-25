using System.ComponentModel;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [TypeConverter(typeof(SqlEnumConverter<SqlUserAuthenticationType>))]
    public enum SqlUserAuthenticationType
        {
        None,
        InstanceAuthentication,
        DatabaseAuthentication,
        WindowsAuthentication,
        ExternalAuthenticationProvider
        }
    }