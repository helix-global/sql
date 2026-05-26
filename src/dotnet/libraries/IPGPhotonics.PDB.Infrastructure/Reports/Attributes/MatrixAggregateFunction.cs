using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(SqlEnumConverter<MatrixAggregateFunction>))]
    public enum MatrixAggregateFunction
        {
        None,
        Sum,
        Min,
        Max,
        Avg,
        Count,
        Custom
        }
    }