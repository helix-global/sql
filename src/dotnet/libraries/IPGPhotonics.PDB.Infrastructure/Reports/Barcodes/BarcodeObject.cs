using System;
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
        [UsedImplicitly][Field] public Int32 Angle { get; }
        [UsedImplicitly][Field] public Boolean AutoSize { get; } = true;
        [UsedImplicitly][Field] public Boolean HideIfNoData { get; } = true;
        [UsedImplicitly][Field] public Boolean ShowText { get; } = true;
        [UsedImplicitly][Field(ConverterCulture="en-US")] public Single Zoom { get; } = 1f;
        [UsedImplicitly][Field] public BarcodeBase Barcode { get; } = new Barcode39();
        }
    }
