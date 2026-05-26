using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(SqlEnumConverter<ColumnFormat>))]
    public enum ColumnFormat
        {
        Auto,
        General,
        Number,
        Currency,
        Date,
        Time,
        Percent,
        Boolean
        }
    }