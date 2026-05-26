using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(SqlEnumConverter<GroupBy>))]
    public enum GroupBy
        {
        None,
        XValue,
        Number,
        Years,
        Months,
        Weeks,
        Days,
        Hours,
        Minutes,
        Seconds,
        Milliseconds
        }
    }
