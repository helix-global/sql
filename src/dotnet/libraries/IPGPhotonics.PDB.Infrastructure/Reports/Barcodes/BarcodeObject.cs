using System;
using System.ComponentModel;
using System.Windows;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("BarcodeObject")]
    internal class BarcodeObject : ReportComponentBase
        {
        [UsedImplicitly][Field(Order=1000403)] public String DataColumn { get; }
        [UsedImplicitly][Field(Order=1000405)] public String Text { get; }
        [UsedImplicitly][Field(Order=1000404)] public String Expression { get; }
        [UsedImplicitly][Field(Order=1000410)] public String NoDataText { get; }
        [UsedImplicitly][Field(Order=1000401)] public Int32 Angle { get; }
        [UsedImplicitly][Field(Order=1000402)][DefaultValue(true)] public Boolean AutoSize { get; } = true;
        [UsedImplicitly][Field(Order=1000409)][DefaultValue(true)] public Boolean HideIfNoData { get; } = true;
        [UsedImplicitly][Field(Order=1000406)][DefaultValue(true)] public Boolean ShowText { get; } = true;
        [UsedImplicitly][Field(Order=1000408,ConverterCulture="en-US")][DefaultValue(1f)] public Single Zoom { get; } = 1f;
        [UsedImplicitly][Field(Order=1000411)][DefaultValue(typeof(Barcode39),"CalcCheckSum=true")] public BarcodeBase Barcode { get; } = new Barcode39();
        [UsedImplicitly][Field(Order=1000407,Converter=typeof(FastReportThicknessConverter))] public Thickness Padding { get; }
        }
    }
