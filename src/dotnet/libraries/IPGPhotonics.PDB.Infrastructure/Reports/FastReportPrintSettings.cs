using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing.Printing;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [TypeConverter(typeof(SqlObjectConverter<FastReportPrintSettings>))]
    internal class FastReportPrintSettings : FastReportObject,IFastReportClassObject,IEquatable<FastReportPrintSettings>
        {
        String IFastReportClassObject.ClassName { get { return "PrintSettings"; }}
        [UsedImplicitly][Field(Order=1000101)] public String Printer { get; }
        [UsedImplicitly][Field(Order=1000102)] public Boolean SavePrinterWithReport { get; }
        [UsedImplicitly][Field(Order=1000103)] public Boolean PrintToFile { get; }
        [UsedImplicitly][Field(Order=1000104)] public String PrintToFileName { get; }
        [UsedImplicitly][Field(Order=1000105)] public PageRange PageRange { get; }
        [UsedImplicitly][Field(Order=1000106)] public String PageNumbers { get; }
        [UsedImplicitly][Field(Order=1000107)][DefaultValue(1)] public Int32 Copies { get; } = 1;
        [UsedImplicitly][Field(Order=1000108)][DefaultValue(true)] public Boolean Collate { get; } = true;
        [UsedImplicitly][Field(Order=1000109)] public PrintPages PrintPages { get; }
        [UsedImplicitly][Field(Order=1000110)] public Boolean Reverse { get; }
        [UsedImplicitly][Field(Order=1000111)] public Duplex Duplex { get; }
        [UsedImplicitly][Field(Order=1000112)][DefaultValue(7)] public Int32 PaperSource { get; } = 7;
        [UsedImplicitly][Field(Order=1000113)] public PrintMode PrintMode { get; }
        [UsedImplicitly][Field(Order=1000114)] public Single PrintOnSheetWidth { get; }
        [UsedImplicitly][Field(Order=1000115)] public Single PrintOnSheetHeight { get; }
        [UsedImplicitly][Field(Order=1000116)] public Int32 PrintOnSheetRawPaperSize { get; }
        [UsedImplicitly][Field(Order=1000117)] public PagesOnSheet PagesOnSheet { get; }
        [UsedImplicitly][Field(Order=1000118)] public Object CopyNames { get; }
        [UsedImplicitly][Field(Order=1000119)][DefaultValue(true)] public Boolean ShowDialog { get; } = true;
        public override IEnumerable<FastReportObject> Children { get {
            return EmptyArray<FastReportObject>.List;
            }}

        #region M:Serialize(IFastReportSerializer,String,Object)
        public override void Serialize(IFastReportSerializer serializer,String prefix,Object other) {
            if (serializer == null) { throw new ArgumentNullException(nameof(serializer)); }
            serializer.Serialize(this,prefix,other);
            }
        #endregion
        #region M:Equals(Object):Boolean
        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns>true if the current object is equal to the other parameter; otherwise, false.</returns>
        public override Boolean Equals(Object other) {
            if (ReferenceEquals(other,null)) { return false; }
            if (ReferenceEquals(this,other)) { return true;  }
            return Equals(other as FastReportPrintSettings);
            }
        #endregion
        #region M:Equals(FastReportPrintSettings):Boolean
        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns>true if the current object is equal to the other parameter; otherwise, false.</returns>
        public Boolean Equals(FastReportPrintSettings other) {
            if (ReferenceEquals(other,null)) { return false; }
            if (ReferenceEquals(this,other)) { return true;  }
            return String.Equals(Printer,other.Printer)
                && (SavePrinterWithReport == other.SavePrinterWithReport)
                && (PrintToFile == other.PrintToFile)
                && String.Equals(PrintToFileName,other.PrintToFileName)
                && (PageRange == other.PageRange)
                && String.Equals(PageNumbers,other.PageNumbers)
                && (Copies == other.Copies)
                && (Collate == other.Collate)
                && (PrintPages == other.PrintPages)
                && (Reverse == other.Reverse)
                && (Duplex == other.Duplex)
                && (PaperSource == other.PaperSource)
                && (PrintMode == other.PrintMode)
                && (PrintOnSheetWidth == other.PrintOnSheetWidth)
                && (PrintOnSheetHeight == other.PrintOnSheetHeight)
                && (PrintOnSheetRawPaperSize == other.PrintOnSheetRawPaperSize)
                && (PagesOnSheet == other.PagesOnSheet)
                && Object.Equals(CopyNames,other.CopyNames)
                && (ShowDialog == other.ShowDialog);
            }
        #endregion
        #region M:GetHashCode:Int32
        /// <summary>Calculates a hash code for the current object.</summary>
        /// <returns>Returns a hash code for the current object.</returns>
        public override Int32 GetHashCode() {
            return HashCodeCombiner.GetHashCode(
                Printer,SavePrinterWithReport,PrintToFile,PrintToFileName,
                PageRange,PageNumbers,Copies,Collate,PrintPages,
                Reverse,Duplex,PaperSource,PrintMode,
                PrintOnSheetWidth,PrintOnSheetHeight,PrintOnSheetRawPaperSize,
                PagesOnSheet,CopyNames,ShowDialog);
            }
        #endregion
        }
    }
