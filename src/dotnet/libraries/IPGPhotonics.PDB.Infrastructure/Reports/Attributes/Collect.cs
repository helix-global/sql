using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(SqlEnumConverter<Collect>))]
    public enum Collect
        {
        None,
        TopN,
        BottomN,
        LessThan,
        LessThanPercent,
        GreaterThan,
        GreaterThanPercent
        }
    }
