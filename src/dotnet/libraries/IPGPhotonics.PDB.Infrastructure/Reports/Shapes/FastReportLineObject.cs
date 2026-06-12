using System;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("LineObject")]
    internal sealed class FastReportLineObject : ReportComponentBase
        {
        [UsedImplicitly][Field(Order=1000401)] public Boolean Diagonal { get; }
        [UsedImplicitly][Field(Order=1000402)] public FastReportCapSettings StartCap { get; } = new FastReportCapSettings();
        [UsedImplicitly][Field(Order=1000403)] public FastReportCapSettings EndCap { get; } = new FastReportCapSettings();

        public FastReportLineObject()
            {
            Border.SimpleBorder = true;
            }
        }
    }
