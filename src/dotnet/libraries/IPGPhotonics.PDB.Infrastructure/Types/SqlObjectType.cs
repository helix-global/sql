using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure
    {
    [TypeConverter(typeof(SqlEnumConverter<SqlAssemblyPermissionSet>))]
    public enum SqlObjectType
        {
        None = 0,
        ScriptBefore         =   10,
        Table                =   20,
        Function             =   30,
        Procedure            =   40,
        Index                =   50,
        Trigger              =   60,
        ForeignKeyConstraint =   70,
        View                 =   80,
        CheckConstraint      =   90,
        Statistics           =  100,
        Assembly             =  200,
        TableType            =  210,
        PartitionFunction    =  220,
        PartitionScheme      =  230,
        ScriptAfter          = 1000,
        }
    }