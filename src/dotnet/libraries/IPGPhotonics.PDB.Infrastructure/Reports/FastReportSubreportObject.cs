using System;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("SubreportObject")]
    internal sealed class FastReportSubreportObject : ReportComponentBase
        {
        [UsedImplicitly][Field(Order=1000402)] public Boolean PrintOnParent { get; }
        [UsedImplicitly][Field(Order=1000401)] public String ReportPage { get; }
        }
    }
