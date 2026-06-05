using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(SqlEnumConverter<FastReportLanguage>))]
    public enum FastReportLanguage
        {
        None,
        CSharp,
        Vb
        }
    }
