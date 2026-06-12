using System.ComponentModel;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(BarcodeConverter<FastReportBarcode39>))]
    internal class FastReportBarcode39 : FastReportLinearBarcodeBase
        {
        }
    }