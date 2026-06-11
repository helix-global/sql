using System.ComponentModel;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(BarcodeConverter<Barcode39>))]
    internal class Barcode39 : LinearBarcodeBase
        {
        public Barcode39()
            {
            return;
            }
        }
    }