using System;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("LineObject")]
    internal sealed class LineObject : ReportComponentBase
        {
        [UsedImplicitly][Field(Order=1000401)] public Boolean Diagonal { get; }
        [UsedImplicitly][Field(Order=1000402)] public CapSettings StartCap { get; } = new CapSettings();
        [UsedImplicitly][Field(Order=1000403)] public CapSettings EndCap { get; } = new CapSettings();
        }
    }
