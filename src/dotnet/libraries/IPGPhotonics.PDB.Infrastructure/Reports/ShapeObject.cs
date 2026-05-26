using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Windows.Media;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;
using IPGPhotonics.PDB.Infrastructure.Reports;

namespace IPGPhotonics.PDB.Infrastructure
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("ShapeObject")]
    internal sealed class ShapeObject : ReportComponentBase
        {
        [UsedImplicitly][Field] public Single Curve { get; }
        [UsedImplicitly][Field] public ShapeKind Shape { get; }
        }
    }
