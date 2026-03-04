using System.ComponentModel;

namespace BinaryStudio.SqlServer.Infrastructure.A2C
    {
    [TypeConverter(typeof(SqlEnumConverter<SqlAssemblyPermissionSet>))]
    internal enum SqlObjectType
        {
        None = 0,
        ScriptBefore = 10,
        Table = 20,
        Function = 30,
        Procedure = 40,
        Index = 50,
        Trigger = 60,
        ForeignKeyConstraint = 70,
        View = 80,
        CheckConstraint =90,
        Statistics = 100,
        Assembly  = 200,
        TableType = 210,
        PartitionFunction = 220,
        PartitionScheme   = 230,
        ScriptAfter = 1000,
        }
    }