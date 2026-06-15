using System;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    internal abstract class FastReportVisitor : IFastReportVisitor
        {
        #region M:Visit(FastReportObject)
        public virtual void Visit(FastReportObject node) { }
        #endregion

        #region FastReport
        public virtual void Visit(FastReport node) { Visit((FastReportBase)node); }
        #endregion

        #region Fills
        public virtual void Visit(FastReportFillBase node)            { Visit((FastReportObject)node);  }
        public virtual void Visit(FastReportSolidFill node)           { Visit((FastReportFillBase)node); }
        public virtual void Visit(FastReportHatchFill node)           { Visit((FastReportFillBase)node); }
        public virtual void Visit(FastReportGlassFill node)           { Visit((FastReportFillBase)node); }
        public virtual void Visit(FastReportLinearGradientFill node)  { Visit((FastReportFillBase)node); }
        public virtual void Visit(FastReportPathGradientFill node)    { Visit((FastReportFillBase)node); }
        #endregion

        #region Border
        public virtual void Visit(FastReportBorder node)     { Visit((FastReportObject)node); }
        public virtual void Visit(FastReportBorderLine node) { Visit((FastReportObject)node); }
        #endregion

        #region Pages
        public virtual void Visit(FastReportPageBase node)    { Visit((FastReportComponentBase)node); }
        public virtual void Visit(FastReportPage node)        { Visit((FastReportPageBase)node);       }
        public virtual void Visit(FastReportDialogPage node)  { Visit((FastReportPageBase)node);       }
        #endregion

        #region Bands
        public virtual void Visit(FastReportBandBase node)             { Visit((FastReportBreakableComponent)node); }
        public virtual void Visit(FastReportHeaderFooterBandBase node) { Visit((FastReportBandBase)node);           }
        public virtual void Visit(FastReportDataBand node)             { Visit((FastReportBandBase)node);           }
        public virtual void Visit(FastReportTitleBand node)            { Visit((FastReportBandBase)node);           }
        public virtual void Visit(FastReportSummaryBand node)          { Visit((FastReportHeaderFooterBandBase)node); }
        public virtual void Visit(FastReportPageHeaderBand node)       { Visit((FastReportBandBase)node);           }
        public virtual void Visit(FastReportPageFooterBand node)       { Visit((FastReportBandBase)node);           }
        public virtual void Visit(FastReportColumnHeaderBand node)     { Visit((FastReportBandBase)node);           }
        public virtual void Visit(FastReportColumnFooterBand node)     { Visit((FastReportBandBase)node);           }
        public virtual void Visit(FastReportGroupHeaderBand node)      { Visit((FastReportHeaderFooterBandBase)node); }
        public virtual void Visit(FastReportGroupFooterBand node)      { Visit((FastReportHeaderFooterBandBase)node); }
        public virtual void Visit(FastReportDataHeaderBand node)       { Visit((FastReportHeaderFooterBandBase)node); }
        public virtual void Visit(FastReportDataFooterBand node)       { Visit((FastReportHeaderFooterBandBase)node); }
        public virtual void Visit(FastReportChildBand node)            { Visit((FastReportBandBase)node);           }
        public virtual void Visit(FastReportOverlayBand node)          { Visit((FastReportBandBase)node);           }
        #endregion

        #region Report components
        public virtual void Visit(ReportComponentBase node)         { Visit((FastReportBreakableComponent)node); }
        public virtual void Visit(FastReportTextObjectBase node)    { Visit((FastReportBreakableComponent)node); }
        public virtual void Visit(FastReportTextObject node)        { Visit((FastReportTextObjectBase)node);    }
        public virtual void Visit(FastReportCellularTextObject node){ Visit((FastReportTextObject)node);        }
        public virtual void Visit(FastReportRichObject node)        { Visit((FastReportTextObjectBase)node);    }
        public virtual void Visit(FastReportPictureObject node)     { Visit((ReportComponentBase)node);         }
        public virtual void Visit(FastReportCheckBoxObject node)    { Visit((ReportComponentBase)node);         }
        public virtual void Visit(FastReportZipCodeObject node)     { Visit((ReportComponentBase)node);         }
        public virtual void Visit(FastReportSubreportObject node)   { Visit((ReportComponentBase)node);         }
        public virtual void Visit(FastReportLineObject node)        { Visit((ReportComponentBase)node);         }
        public virtual void Visit(FastReportShapeObject node)       { Visit((ReportComponentBase)node);         }
        public virtual void Visit(FastReportChartObject node)       { Visit((ReportComponentBase)node);         }
        public virtual void Visit(FastReportBarcodeObject node)     { Visit((ReportComponentBase)node);         }
        #endregion

        #region Tables
        public virtual void Visit(FastReportTableBase node)     { Visit((FastReportBreakableComponent)node); }
        public virtual void Visit(FastReportTableObject node)   { Visit((FastReportTableBase)node);          }
        public virtual void Visit(FastReportMatrixObject node)  { Visit((FastReportTableBase)node);          }
        public virtual void Visit(FastReportTableRow node)      { Visit((FastReportObject)node);             }
        public virtual void Visit(FastReportTableColumn node)   { Visit((FastReportObject)node);             }
        public virtual void Visit(FastReportTableCell node)     { Visit((FastReportObject)node);             }
        #endregion

        #region Dialog controls
        public virtual void Visit(FastReportDialogComponentBase node)    { Visit((FastReportComponentBase)node);        }
        public virtual void Visit(FastReportDialogControl node)          { Visit((FastReportDialogComponentBase)node);  }
        public virtual void Visit(FastReportBindableDialogControl node)  { Visit((FastReportDialogControl)node);        }
        public virtual void Visit(FastReportDataFilterBaseControl node)  { Visit((FastReportDialogControl)node);        }
        public virtual void Visit(FastReportParentControl node)          { Visit((FastReportDialogControl)node);        }
        public virtual void Visit(FastReportButtonBaseControl node)      { Visit((FastReportDialogControl)node);        }
        public virtual void Visit(FastReportButtonControl node)          { Visit((FastReportButtonBaseControl)node);    }
        public virtual void Visit(FastReportLabelControl node)           { Visit((FastReportDialogControl)node);        }
        public virtual void Visit(FastReportTextBoxControl node)         { Visit((FastReportDialogControl)node);        }
        public virtual void Visit(FastReportMaskedTextBoxControl node)   { /*Visit((FastReportTextBoxControl)node);*/       }
        public virtual void Visit(FastReportCheckBoxControl node)        { Visit((FastReportDialogControl)node);        }
        public virtual void Visit(FastReportRadioButtonControl node)     { Visit((FastReportDialogControl)node);        }
        public virtual void Visit(FastReportComboBoxControl node)        { Visit((FastReportDialogControl)node);        }
        public virtual void Visit(FastReportListBoxBaseControl node)     { Visit((FastReportDialogControl)node);        }
        public virtual void Visit(FastReportListBoxControl node)         { Visit((FastReportListBoxBaseControl)node);   }
        public virtual void Visit(FastReportCheckedListBoxControl node)  { Visit((FastReportListBoxBaseControl)node);   }
        public virtual void Visit(FastReportPictureBoxControl node)      { Visit((FastReportDialogControl)node);        }
        public virtual void Visit(FastReportGridControl node)            { Visit((FastReportDialogControl)node);        }
        public virtual void Visit(FastReportListViewControl node)        { Visit((FastReportDialogControl)node);        }
        public virtual void Visit(FastReportTreeViewControl node)        { Visit((FastReportDialogControl)node);        }
        public virtual void Visit(FastReportCheckedTreeViewControl node) { /*Visit((FastReportTreeViewControl)node);*/      }
        public virtual void Visit(FastReportDateTimePickerControl node)  { Visit((FastReportDialogControl)node);        }
        public virtual void Visit(FastReportMonthCalendarControl node)   { Visit((FastReportDialogControl)node);        }
        public virtual void Visit(FastReportNumericUpDownControl node)   { Visit((FastReportDialogControl)node);        }
        public virtual void Visit(FastReportRichTextBoxControl node)     { Visit((FastReportDialogControl)node);        }
        public virtual void Visit(FastReportGroupBoxControl node)        { Visit((FastReportParentControl)node);        }
        public virtual void Visit(FastReportPanelControl node)           { Visit((FastReportParentControl)node);        }
        public virtual void Visit(FastReportPickControl node)            { /*Visit((FastReportDataFilterBaseControl)node);*/ }
        public virtual void Visit(FastReportDataSelectorControl node)    { Visit((FastReportDataFilterBaseControl)node); }
        public virtual void Visit(FastReportMonthSelectorControl node)   { /*Visit((FastReportDataFilterBaseControl)node);*/ }
        public virtual void Visit(FastReportDatePeriodReportControl node){ Visit((FastReportDataFilterBaseControl)node); }
        #endregion

        #region Styles / Conditions
        public virtual void Visit(FastReportStyleBase node)          { Visit((FastReportObject)node);      }
        public virtual void Visit(FastReportStyle node)              { Visit((FastReportStyleBase)node);   }
        public virtual void Visit(FastReportHighlightCondition node) { Visit((FastReportStyleBase)node);   }
        #endregion

        #region Data
        public virtual void Visit(FastReportDataComponentBase node)       { Visit((FastReportObject)node);           }
        public virtual void Visit(FastReportDataSourceBase node)          { Visit((FastReportDataComponentBase)node); }
        public virtual void Visit(FastReportDataConnectionBase node)      { Visit((FastReportDataComponentBase)node); }
        public virtual void Visit(MsSqlDataConnection node)               { Visit((FastReportDataConnectionBase)node); }
        public virtual void Visit(FastReportViewDataSource node)          { Visit((FastReportDataSourceBase)node);    }
        public virtual void Visit(FastReportTableDataSource node)         { Visit((FastReportDataSourceBase)node);    }
        public virtual void Visit(FastReportBusinessObjectDataSource node){ Visit((FastReportDataSourceBase)node);    }
        public virtual void Visit(FastReportRelation node)                { Visit((FastReportObject)node);            }
        public virtual void Visit(FastReportParameter node)               { Visit((FastReportObject)node);            }
        public virtual void Visit(FastReportTotal node)                   { Visit((FastReportObject)node);            }
        public virtual void Visit(FastReportColumn node)                  { Visit((FastReportObject)node);            }
        #endregion

        #region Variables
        public virtual void Visit(FastReportSystemVariable node)             { Visit((FastReportObject)node); }
        public virtual void Visit(FastReportPageVariable node)               { Visit((FastReportSystemVariable)node); }
        public virtual void Visit(FastReportPageMacroVariable node)          { Visit((FastReportSystemVariable)node); }
        public virtual void Visit(FastReportTotalPagesVariable node)         { Visit((FastReportSystemVariable)node); }
        public virtual void Visit(FastReportTotalPagesMacroVariable node)    { Visit((FastReportSystemVariable)node); }
        public virtual void Visit(FastReportRowVariable node)                { Visit((FastReportSystemVariable)node); }
        public virtual void Visit(FastReportAbsRowVariable node)             { Visit((FastReportSystemVariable)node); }
        public virtual void Visit(FastReportHierarchyRowNoVariable node)     { Visit((FastReportSystemVariable)node); }
        public virtual void Visit(FastReportHierarchyLevelVariable node)     { Visit((FastReportSystemVariable)node); }
        public virtual void Visit(FastReportDateVariable node)               { Visit((FastReportSystemVariable)node); }
        public virtual void Visit(FastReportCopyNameMacroVariable node)      { Visit((FastReportSystemVariable)node); }
        public virtual void Visit(FastReportPageNVariable node)              { Visit((FastReportSystemVariable)node); }
        public virtual void Visit(FastReportPageNofMVariable node)           { Visit((FastReportSystemVariable)node); }
        #endregion

        #region Misc
        public virtual void Visit(FastReportSort node)                    { Visit((FastReportObject)node); }
        public virtual void Visit(FastReportWatermark node)               { Visit((FastReportObject)node); }
        public virtual void Visit(FastReportHyperlink node)               { Visit((FastReportObject)node); }
        public virtual void Visit(FastReportCapSettings node)             { Visit((FastReportObject)node); }
        public virtual void Visit(FastReportInfo node)                    { Visit((FastReportObject)node); }
        public virtual void Visit(FastReportPrintSettings node)           { Visit((FastReportObject)node); }
        public virtual void Visit(FastReportBandColumns node)             { Visit((FastReportObject)node); }
        public virtual void Visit(FastReportPageColumns node)             { Visit((FastReportObject)node); }
        public virtual void Visit(FastReportChartSeries node)             { Visit((FastReportObject)node); }
        //public virtual void Visit(FastReportFilterOperation node)         { Visit((FastReportObject)node); }
        public virtual void Visit(FastReportMatrixHeaderDescriptor node)  { Visit((FastReportObject)node); }
        public virtual void Visit(FastReportMatrixCellDescriptor node)    { Visit((FastReportObject)node); }
        public virtual void Visit(FastReportCompanyLogoControl node)      { Visit((ReportComponentBase)node); }
        #endregion

        #region Formats
        public virtual void Visit(FastReportFormatBase node)     { Visit((FastReportObject)node);        }
        public virtual void Visit(FastReportGeneralFormat node)  { Visit((FastReportFormatBase)node);    }
        public virtual void Visit(FastReportNumberFormat node)   { Visit((FastReportFormatBase)node);    }
        public virtual void Visit(FastReportCurrencyFormat node) { Visit((FastReportFormatBase)node);    }
        public virtual void Visit(FastReportDateFormat node)     { Visit((FastReportFormatBase)node);    }
        public virtual void Visit(FastReportTimeFormat node)     { Visit((FastReportFormatBase)node);    }
        public virtual void Visit(FastReportPercentFormat node)  { Visit((FastReportFormatBase)node);    }
        public virtual void Visit(FastReportBooleanFormat node)  { Visit((FastReportFormatBase)node);    }
        public virtual void Visit(FastReportCustomFormat node)   { Visit((FastReportFormatBase)node);    }
        #endregion

        #region M:Visit(FastReportBase)
        protected virtual void Visit(FastReportBase node)             { Visit((FastReportObject)node);             }
        #endregion
        #region M:Visit(FastReportComponentBase)
        protected virtual void Visit(FastReportComponentBase node)    { Visit((FastReportBase)node);               }
        #endregion
        #region M:Visit(FastReportBreakableComponent)
        protected virtual void Visit(FastReportBreakableComponent node) { Visit((ReportComponentBase)node); }
        #endregion
        }
    }
