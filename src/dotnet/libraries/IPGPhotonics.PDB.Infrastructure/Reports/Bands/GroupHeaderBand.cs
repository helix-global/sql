using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("GroupHeaderBand")]
    internal sealed class GroupHeaderBand : HeaderFooterBandBase
        {
        [UsedImplicitly][Field] public String Condition { get; }
        [UsedImplicitly][Field] public Boolean KeepTogether { get; }
        [UsedImplicitly][Field] public Boolean ResetPageNumber { get; }
        [UsedImplicitly][Field] public SortOrder SortOrder { get; } = SortOrder.Ascending;
        }
    }
