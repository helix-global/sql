using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(SqlEnumConverter<TotalType>))]
    public enum TotalType
        {
        Sum,
        Min,
        Max,
        Avg,
        Count
        }
    }