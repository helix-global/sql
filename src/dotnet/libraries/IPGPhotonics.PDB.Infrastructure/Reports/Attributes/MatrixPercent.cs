using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(SqlEnumConverter<MatrixPercent>))]
    public enum MatrixPercent
        {
        None,
        ColumnTotal,
        RowTotal,
        GrandTotal
        }
    }