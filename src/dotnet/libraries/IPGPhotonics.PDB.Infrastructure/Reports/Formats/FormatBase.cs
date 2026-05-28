using System.ComponentModel;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(FormatConverter))]
    public class FormatBase : FastReportObject
        {
        }
    }