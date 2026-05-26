using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(SqlEnumConverter<ProcessAt>))]
    public enum ProcessAt
        {
        Default,
        ReportFinished,
        ReportPageFinished,
        PageFinished,
        ColumnFinished,
        DataFinished,
        GroupFinished,
        Custom
        }
    }