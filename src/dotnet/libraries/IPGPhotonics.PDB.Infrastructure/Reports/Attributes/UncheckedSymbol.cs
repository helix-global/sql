using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(SqlEnumConverter<UncheckedSymbol>))]
    public enum UncheckedSymbol
        {
        None,
        Cross,
        Minus
        }
    }