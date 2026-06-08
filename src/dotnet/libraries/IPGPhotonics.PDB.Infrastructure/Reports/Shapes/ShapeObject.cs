using System;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("ShapeObject")]
    internal sealed class ShapeObject : ReportComponentBase
        {
        [UsedImplicitly][Field(ConverterCulture="en-US")] public Single Curve { get; }
        [UsedImplicitly][Field] public ShapeKind Shape { get; }
        }
    }
