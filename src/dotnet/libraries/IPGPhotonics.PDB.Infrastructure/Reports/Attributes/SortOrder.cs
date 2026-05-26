using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(SqlEnumConverter<SortOrder>))]
    public enum SortOrder
        {
        None,
        Ascending,
        Descending
        }
    }