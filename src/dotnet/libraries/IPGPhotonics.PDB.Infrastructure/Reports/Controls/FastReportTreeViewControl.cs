using System;
using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("TreeViewControl")]
    internal sealed class FastReportTreeViewControl : FastReportDialogControl
        {
        [UsedImplicitly][Field(Order=1000504)] public String AfterSelectEvent { get; }
        [UsedImplicitly][Field(Order=1000501)] public Boolean CheckBoxes { get; }
        [UsedImplicitly][Field(Order=1000502)][DefaultValue(true)] public Boolean ShowLines { get; } = true;
        [UsedImplicitly][Field(Order=1000503)][DefaultValue(true)] public Boolean ShowRootLines { get; } = true;
        }
    }
