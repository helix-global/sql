using System.ComponentModel;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(FastReportBarcodeConverter<FastReportBarcode39>))]
    internal class FastReportBarcode39 : FastReportLinearBarcodeBase
        {
        }
    }