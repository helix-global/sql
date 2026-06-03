using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    internal interface IFastReportVisitor
        {
        void Visit(DataConnectionBase o);
        void Visit(TextObject o);
        void Visit(BandColumns o);
        void Visit(ChildBand o);
        void Visit(ColumnFooterBand o);
        void Visit(ColumnHeaderBand o);
        void Visit(CrossBandObject o);
        void Visit(DataBand o);
        void Visit(DataFooterBand o);
        void Visit(DataHeaderBand o);
        void Visit(GroupFooterBand o);
        void Visit(GroupHeaderBand o);
        void Visit(OverlayBand o);
        void Visit(PageFooterBand o);
        void Visit(PageHeaderBand o);
        void Visit(ReportSummaryBand o);
        void Visit(ReportTitleBand o);
        void Visit(TableObject o);
        void Visit(Barcode128 o);
        void Visit(Barcode2of5Industrial o);
        void Visit(Barcode2of5Matrix o);
        void Visit(Barcode39 o);
        void Visit(Barcode93 o);
        void Visit(BarcodeCodabar o);
        void Visit(BarcodeDatamatrix o);
        void Visit(BarcodeEAN13 o);
        void Visit(BarcodeEAN8 o);
        void Visit(BarcodeMSI o);
        void Visit(BarcodeObject o);
        void Visit(BarcodePDF417 o);
        void Visit(BarcodePostNet o);
        void Visit(BarcodeQR o);
        void Visit(BarcodeUPC_E0 o);
        void Visit(FastReport o);
        void Visit(Column o);
        void Visit(TableDataSource o);
        void Visit(CommandParameter o);
        void Visit(FastReportParameter o);
        void Visit(PageBase o);
        }
    }
