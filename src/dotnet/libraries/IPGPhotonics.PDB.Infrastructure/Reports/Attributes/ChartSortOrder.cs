using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(SqlEnumConverter<ChartSortOrder>))]
    public enum ChartSortOrder
        {
        Ascending,
        Descending
        }
    }