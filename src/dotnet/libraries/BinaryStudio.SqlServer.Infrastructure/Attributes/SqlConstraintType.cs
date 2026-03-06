using System.ComponentModel;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [TypeConverter(typeof(SqlEnumConverter<SqlConstraintType>))]
    public enum SqlConstraintType
        {
        Null,
        NotNull,
        PrimaryKey,
        Unique,
        Identity,
        Default,
        Check,
        ForeignKey,
        RowGuidCol,
        Edge
        }
    }
