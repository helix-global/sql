using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(SqlEnumConverter<MatrixEvenStylePriority>))]
    public enum MatrixEvenStylePriority
        {
        Rows,
        Columns
        }
    }