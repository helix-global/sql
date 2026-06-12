using System;
using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("GroupHeaderBand")]
    internal sealed class FastReportGroupHeaderBand : FastReportHeaderFooterBandBase
        {
        [UsedImplicitly][Field(Order=1000701)] public String Condition { get; }
        [UsedImplicitly][Field(Order=1000703)] public Boolean KeepTogether { get; }
        [UsedImplicitly][Field(Order=1000704)] public Boolean ResetPageNumber { get; }
        [UsedImplicitly][Field(Order=1000702)][DefaultValue(SortOrder.Ascending)] public SortOrder SortOrder { get; } = SortOrder.Ascending;
        }
    }
