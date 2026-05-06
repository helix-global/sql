using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure
    {
    [TypeConverter(typeof(SqlEnumConverter<DatePeriodType>))]
    public enum DatePeriodType
        {
        None = 0,
        Day  = 10,
        Week = 15,
        Month = 20,
        Year = 30,
        Custom = 100,
        All = 200
        }
    }