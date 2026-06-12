using System;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("ShapeObject")]
    internal sealed class FastReportShapeObject : ReportComponentBase
        {
        [UsedImplicitly][Field(Order=1000402,ConverterCulture="en-US")] public Single Curve { get; }
        [UsedImplicitly][Field(Order=1000401)] public ShapeKind Shape { get; }

        public FastReportShapeObject()
            {
            Border.SimpleBorder = true;
            }
        }
    }
