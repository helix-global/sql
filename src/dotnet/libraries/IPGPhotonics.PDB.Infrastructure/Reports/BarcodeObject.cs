using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("BarcodeObject")]
    internal class BarcodeObject : ReportComponentBase
        {
        [UsedImplicitly][Field] public String DataColumn { get; }
        [UsedImplicitly][Field] public String Text { get; }
        [UsedImplicitly][Field] public String Expression { get; }
        [UsedImplicitly][Field] public String NoDataText { get; }
        [UsedImplicitly][Field] public String SymbologyName { get; }
        [UsedImplicitly][Field] public String Barcode { get; } = "39";
        [UsedImplicitly][Field] public Int32 Angle { get; }
        [UsedImplicitly][Field] public Boolean AutoSize { get; } = true;
        [UsedImplicitly][Field] public Boolean HideIfNoData { get; } = true;
        [UsedImplicitly][Field] public Boolean ShowText { get; } = true;
        [UsedImplicitly][Field] public Single Zoom { get; } = 1f;
        [UsedImplicitly][Field("Barcode.SymbolSize")] public DatamatrixSymbolSize BarcodeSymbolSize { get; }
        [UsedImplicitly][Field("Barcode.Encoding")] public DatamatrixEncoding BarcodeEncoding { get; }
        [UsedImplicitly][Field("Barcode.CodePage")] public Int32 BarcodeCodePage { get; } = 1252;
        [UsedImplicitly][Field("Barcode.PixelSize")] public Int32 BarcodePixelSize { get; } = 3;
        }
    }
