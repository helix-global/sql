using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    internal abstract class FastReportVisitor : IFastReportVisitor
        {
        #region M:Visit<T>(IEnumerable<T>)
        protected void Visit<T>(IEnumerable<T> objects)
            where T: FastReportObject
            {
            foreach (var o in objects)
                {
                o.Accept(this);
                }
            }
        #endregion

        public virtual void Visit(TextObject o)
            {
            if (o == null) { throw new ArgumentNullException(nameof(o)); }
            Visit(o.Children);
            }

        public virtual void Visit(BandColumns o)
            {
            Visit(o.Children);
            }

        public virtual void Visit(ChildBand o)
            {
            Visit(o.Children);
            }

        public virtual void Visit(ColumnFooterBand o)
            {
            Visit(o.Children);
            }

        public virtual void Visit(ColumnHeaderBand o)
            {
            Visit(o.Children);
            }

        public virtual void Visit(CrossBandObject o)
            {
            Visit(o.Children);
            }

        public virtual void Visit(DataBand o)
            {
            Visit(o.Children);
            }

        public virtual void Visit(DataFooterBand o)
            {
            Visit(o.Children);
            }

        public virtual void Visit(DataHeaderBand o)
            {
            Visit(o.Children);
            }

        public virtual void Visit(GroupFooterBand o)
            {
            Visit(o.Children);
            }

        public virtual void Visit(GroupHeaderBand o)
            {
            Visit(o.Children);
            }

        public virtual void Visit(OverlayBand o)
            {
            Visit(o.Children);
            }

        public virtual void Visit(PageFooterBand o)
            {
            Visit(o.Children);
            }

        public virtual void Visit(PageHeaderBand o)
            {
            Visit(o.Children);
            }

        public virtual void Visit(ReportSummaryBand o)
            {
            Visit(o.Children);
            }

        public virtual void Visit(ReportTitleBand o)
            {
            Visit(o.Children);
            }

        public virtual void Visit(TableObject o)
            {
            Visit(o.Children);
            }

        public virtual void Visit(Barcode128 o)
            {
            Visit(o.Children);
            }

        public virtual void Visit(Barcode2of5Industrial o)
            {
            Visit(o.Children);
            }

        public virtual void Visit(Barcode2of5Matrix o)
            {
            Visit(o.Children);
            }

        public virtual void Visit(Barcode39 o)
            {
            Visit(o.Children);
            }

        public virtual void Visit(Barcode93 o)
            {
            Visit(o.Children);
            }

        public virtual void Visit(BarcodeCodabar o)
            {
            Visit(o.Children);
            }

        public virtual void Visit(BarcodeDatamatrix o)
            {
            Visit(o.Children);
            }

        public virtual void Visit(BarcodeEAN13 o)
            {
            Visit(o.Children);
            }

        public virtual void Visit(BarcodeEAN8 o)
            {
            Visit(o.Children);
            }

        public virtual void Visit(BarcodeMSI o)
            {
            Visit(o.Children);
            }

        public virtual void Visit(BarcodeObject o)
            {
            Visit(o.Children);
            }

        public virtual void Visit(BarcodePDF417 o)
            {
            Visit(o.Children);
            }

        public virtual void Visit(BarcodePostNet o)
            {
            Visit(o.Children);
            }

        public virtual void Visit(BarcodeQR o)
            {
            Visit(o.Children);
            }

        public virtual void Visit(BarcodeUPC_E0 o)
            {
            Visit(o.Children);
            }

        #region M:Visit(FastReport)
        public virtual void Visit(FastReport o)
            {
            if (o == null) { throw new ArgumentNullException(nameof(o)); }
            Visit(o.Children);
            }
        #endregion
        #region M:Visit(DataConnectionBase)
        public virtual void Visit(DataConnectionBase o)
            {
            Visit(o.Children);
            }
        #endregion
        #region M:Visit(Column)
        public virtual void Visit(Column o)
            {
            Visit(o.Children);
            }
        #endregion
        #region M:Visit(TableDataSource)
        public virtual void Visit(TableDataSource o)
            {
            Visit(o.Children);
            }
        #endregion
        #region M:Visit(CommandParameter)
        public virtual void Visit(CommandParameter o)
            {
            Visit(o.Children);
            }
        #endregion
        }
    }
