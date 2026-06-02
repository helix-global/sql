using System.ComponentModel;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(FormatConverter))]
    internal abstract class FormatBase : FastReportObject
        {
        }
    }