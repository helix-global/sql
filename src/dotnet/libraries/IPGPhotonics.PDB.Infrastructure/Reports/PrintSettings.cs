using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;
using System;
using System.Collections.Generic;
using System.Xml;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal class PrintSettings : FastReportObject
        {
        [UsedImplicitly][Field(Order=1000101)] public String Printer { get; }
        [UsedImplicitly][Field(Order=1000102)] public Boolean SavePrinterWithReport { get; }
        [UsedImplicitly][Field(Order=1000103)] public Boolean PrintToFile { get; }
        [UsedImplicitly][Field(Order=1000104)] public String PrintToFileName { get; }
        [UsedImplicitly][Field(Order=1000105)] public Object PageRange { get; }
        [UsedImplicitly][Field(Order=1000106)] public Object PageNumbers { get; }
        [UsedImplicitly][Field(Order=1000107)] public Object Copies { get; }
        [UsedImplicitly][Field(Order=1000108)] public Object Collate { get; }
        [UsedImplicitly][Field(Order=1000109)] public Object PrintPages { get; }
        [UsedImplicitly][Field(Order=1000110)] public Object Reverse { get; }
        [UsedImplicitly][Field(Order=1000111)] public Object Duplex { get; }
        [UsedImplicitly][Field(Order=1000112)] public Object PaperSource { get; }
        [UsedImplicitly][Field(Order=1000113)] public Object PrintMode { get; }
        [UsedImplicitly][Field(Order=1000114)] public Object PrintOnSheetWidth { get; }
        [UsedImplicitly][Field(Order=1000115)] public Object PrintOnSheetHeight { get; }
        [UsedImplicitly][Field(Order=1000116)] public Object PrintOnSheetRawPaperSize { get; }
        [UsedImplicitly][Field(Order=1000117)] public Object PagesOnSheet { get; }
        [UsedImplicitly][Field(Order=1000118)] public Object CopyNames { get; }
        [UsedImplicitly][Field(Order=1000119)] public Object ShowDialog { get; }
        public override IEnumerable<FastReportObject> Children { get {
            return EmptyArray<FastReportObject>.List;
            }}

        #region M:Serialize(XmlWriter,String,Object)
        public override void Serialize(XmlWriter writer,String prefix,Object other) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            SerializeAttributes(writer,prefix);
            }
        #endregion
        }
    }
