using System;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("SubreportObject")]
    internal sealed class SubreportObject : ReportComponentBase
        {
        [UsedImplicitly][Field] public Boolean PrintOnParent { get; }
        [UsedImplicitly][Field] public String ReportPage { get; }
        }
    }
