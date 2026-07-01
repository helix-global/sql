using System;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    internal interface IFastReportSerializer
        {
        void Serialize<T>(T source,String prefix,Object other) where T: FastReportObject;
        void Serialize(FastReportInfo source,String prefix,Object other);
        void Serialize(FastReport source,String prefix,Object other);
        void Serialize(FastReportBorder source,String prefix,Object other);
        void Serialize(FastReportBorderLine source,String prefix,Object other);
        void Serialize(FastReportBandColumns source,String prefix,Object other);
        void Serialize(FastReportBarcodeBase source,String prefix,Object other);
        void Serialize(FastReportCapSettings source,String prefix,Object other);
        void Serialize(FastReportChartObject source,String prefix,Object other);
        void Serialize(FastReportCurrencyFormat source,String prefix,Object other);
        void Serialize(FastReportDataBand source,String prefix,Object other);
        void Serialize(FastReportFillBase source,String prefix,Object other);
        void Serialize(FastReportFormatBase source,String prefix,Object other);
        void Serialize(FastReportGridControl source,String prefix,Object other);
        void Serialize(FastReportHyperlink source,String prefix,Object other);
        void Serialize(FastReportMatrixObject source,String prefix,Object other);
        void Serialize(FastReportNumberFormat source,String prefix,Object other);
        void Serialize(FastReportPageColumns source,String prefix,Object other);
        void Serialize(FastReportPercentFormat source,String prefix,Object other);
        void Serialize(FastReportPickControl source,String prefix,Object other);
        void Serialize(FastReportPictureObject source,String prefix,Object other);
        void Serialize(FastReportPrintSettings source,String prefix,Object other);
        void Serialize(FastReportRichObject source,String prefix,Object other);
        void Serialize(FastReportSolidFill source,String prefix,Object other);
        void Serialize(FastReportTableDataSource source,String prefix,Object other);
        void Serialize(FastReportTextObject source,String prefix,Object other);
        void Serialize(FastReportWatermark source,String prefix,Object other);
        }
    }
