using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(SqlEnumConverter<TableLayout>))]
    public enum TableLayout
        {
        AcrossThenDown,
        DownThenAcross,
        Wrapped
        }
    }