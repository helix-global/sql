using System;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    internal interface IFastReportVisitor
        {
        void Visit(FastReportObject node);

        #region FastReport
        void Visit(FastReport node);
        #endregion
        #region Fills
        void Visit(FastReportFillBase node);
        void Visit(FastReportSolidFill node);
        void Visit(FastReportHatchFill node);
        void Visit(FastReportGlassFill node);
        void Visit(FastReportLinearGradientFill node);
        void Visit(FastReportPathGradientFill node);
        #endregion
        #region Border
        void Visit(FastReportBorder node);
        void Visit(FastReportBorderLine node);
        #endregion
        #region Pages
        void Visit(FastReportPageBase node);
        void Visit(FastReportPage node);
        void Visit(FastReportDialogPage node);
        #endregion
        #region Bands
        void Visit(FastReportBandBase node);
        void Visit(FastReportHeaderFooterBandBase node);
        void Visit(FastReportDataBand node);
        void Visit(FastReportTitleBand node);
        void Visit(FastReportSummaryBand node);
        void Visit(FastReportPageHeaderBand node);
        void Visit(FastReportPageFooterBand node);
        void Visit(FastReportColumnHeaderBand node);
        void Visit(FastReportColumnFooterBand node);
        void Visit(FastReportGroupHeaderBand node);
        void Visit(FastReportGroupFooterBand node);
        void Visit(FastReportDataHeaderBand node);
        void Visit(FastReportDataFooterBand node);
        void Visit(FastReportChildBand node);
        void Visit(FastReportOverlayBand node);
        #endregion
        #region Report components
        void Visit(ReportComponentBase node);
        void Visit(FastReportTextObjectBase node);
        void Visit(FastReportTextObject node);
        void Visit(FastReportCellularTextObject node);
        void Visit(FastReportRichObject node);
        void Visit(FastReportPictureObject node);
        void Visit(FastReportCheckBoxObject node);
        void Visit(FastReportZipCodeObject node);
        void Visit(FastReportSubreportObject node);
        void Visit(FastReportLineObject node);
        void Visit(FastReportShapeObject node);
        void Visit(FastReportChartObject node);
        void Visit(FastReportBarcodeObject node);
        #endregion
        #region Tables
        void Visit(FastReportTableBase node);
        void Visit(FastReportTableObject node);
        void Visit(FastReportMatrixObject node);
        void Visit(FastReportTableRow node);
        void Visit(FastReportTableColumn node);
        void Visit(FastReportTableCell node);
        #endregion
        #region Dialog controls
        void Visit(FastReportDialogComponentBase node);
        void Visit(FastReportDialogControl node);
        void Visit(FastReportBindableDialogControl node);
        void Visit(FastReportDataFilterBaseControl node);
        void Visit(FastReportParentControl node);
        void Visit(FastReportButtonBaseControl node);
        void Visit(FastReportButtonControl node);
        void Visit(FastReportLabelControl node);
        void Visit(FastReportTextBoxControl node);
        void Visit(FastReportMaskedTextBoxControl node);
        void Visit(FastReportCheckBoxControl node);
        void Visit(FastReportRadioButtonControl node);
        void Visit(FastReportComboBoxControl node);
        void Visit(FastReportListBoxBaseControl node);
        void Visit(FastReportListBoxControl node);
        void Visit(FastReportCheckedListBoxControl node);
        void Visit(FastReportPictureBoxControl node);
        void Visit(FastReportGridControl node);
        void Visit(FastReportListViewControl node);
        void Visit(FastReportTreeViewControl node);
        void Visit(FastReportCheckedTreeViewControl node);
        void Visit(FastReportDateTimePickerControl node);
        void Visit(FastReportMonthCalendarControl node);
        void Visit(FastReportNumericUpDownControl node);
        void Visit(FastReportRichTextBoxControl node);
        void Visit(FastReportGroupBoxControl node);
        void Visit(FastReportPanelControl node);
        void Visit(FastReportPickControl node);
        void Visit(FastReportDataSelectorControl node);
        void Visit(FastReportMonthSelectorControl node);
        void Visit(FastReportDatePeriodReportControl node);
        #endregion
        #region Styles / Conditions
        void Visit(FastReportStyleBase node);
        void Visit(FastReportStyle node);
        void Visit(FastReportHighlightCondition node);
        #endregion
        #region Data
        void Visit(FastReportDataComponentBase node);
        void Visit(FastReportDataSourceBase node);
        void Visit(FastReportDataConnectionBase node);
        void Visit(MsSqlDataConnection node);
        void Visit(FastReportViewDataSource node);
        void Visit(FastReportTableDataSource node);
        void Visit(FastReportBusinessObjectDataSource node);
        void Visit(FastReportRelation node);
        void Visit(FastReportParameter node);
        void Visit(FastReportTotal node);
        void Visit(FastReportColumn node);
        #endregion
        #region Variables
        void Visit(FastReportSystemVariable node);
        void Visit(FastReportPageVariable node);
        void Visit(FastReportPageMacroVariable node);
        void Visit(FastReportTotalPagesVariable node);
        void Visit(FastReportTotalPagesMacroVariable node);
        void Visit(FastReportRowVariable node);
        void Visit(FastReportAbsRowVariable node);
        void Visit(FastReportHierarchyRowNoVariable node);
        void Visit(FastReportHierarchyLevelVariable node);
        void Visit(FastReportDateVariable node);
        void Visit(FastReportCopyNameMacroVariable node);
        void Visit(FastReportPageNVariable node);
        void Visit(FastReportPageNofMVariable node);
        #endregion
        #region Misc
        void Visit(FastReportSort node);
        void Visit(FastReportWatermark node);
        void Visit(FastReportHyperlink node);
        void Visit(FastReportCapSettings node);
        void Visit(FastReportInfo node);
        void Visit(FastReportPrintSettings node);
        void Visit(FastReportBandColumns node);
        void Visit(FastReportPageColumns node);
        void Visit(FastReportChartSeries node);
        //void Visit(FastReportFilterOperation node);
        void Visit(FastReportMatrixHeaderDescriptor node);
        void Visit(FastReportMatrixCellDescriptor node);
        void Visit(FastReportCompanyLogoControl node);
        #endregion
        #region Formats
        void Visit(FastReportFormatBase node);
        void Visit(FastReportGeneralFormat node);
        void Visit(FastReportNumberFormat node);
        void Visit(FastReportCurrencyFormat node);
        void Visit(FastReportDateFormat node);
        void Visit(FastReportTimeFormat node);
        void Visit(FastReportPercentFormat node);
        void Visit(FastReportBooleanFormat node);
        void Visit(FastReportCustomFormat node);
        #endregion
        }
    }
