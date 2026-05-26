using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(SqlEnumConverter<CheckedSymbol>))]
    public enum CheckedSymbol
        {
        Check,
        Cross,
        Plus,
        Fill
        }
    }