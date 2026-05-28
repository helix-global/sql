using System;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("LineObject")]
    internal sealed class LineObject : ReportComponentBase
        {
        [UsedImplicitly][Field] public Boolean Diagonal { get; }
        [UsedImplicitly][Field] public CapSettings StartCap { get; } = new CapSettings();
        [UsedImplicitly][Field] public CapSettings EndCap { get; } = new CapSettings();
        }
    }
