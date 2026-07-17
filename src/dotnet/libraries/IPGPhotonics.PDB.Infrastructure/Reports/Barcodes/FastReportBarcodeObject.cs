using System;
using System.ComponentModel;
using System.Windows;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("BarcodeObject")]
    internal class FastReportBarcodeObject : ReportComponentBase
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
        [UsedImplicitly][Field(Order=1000411)][DefaultValue(typeof(FastReportBarcode39),"CalcCheckSum=true")] public FastReportBarcodeBase Barcode { get; } = new FastReportBarcode39();
        [UsedImplicitly][Field(Order=1000407,Converter=typeof(FastReportThicknessConverter))] public Thickness Padding { get; }

        #region M:Serialize(IFastReportSerializer,String,Object)
        public override void Serialize(IFastReportSerializer serializer,String prefix,Object other) {
            if (serializer == null) { throw new ArgumentNullException(nameof(serializer)); }
            serializer.Serialize(this,prefix,other);
            }
        #endregion
        }
    }
