using System.ComponentModel;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [TypeConverter(typeof(SqlEnumConverter<SqlForeignKeyAction>))]
    public enum SqlForeignKeyAction
        {
        NoAction,
        Cascade,
        SetNull,
        SetDefault
        }
    }
