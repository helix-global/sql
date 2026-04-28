using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure
    {
    [TypeConverter(typeof(SqlEnumConverter<EntityStateKind>))]
    public enum EntityStateKind
        {
        None = 0,
        EntityHasStates = 1
        }
    }
