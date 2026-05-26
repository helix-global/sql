using System;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("TreeViewControl")]
    internal sealed class TreeViewControl : DialogControl
        {
        [UsedImplicitly][Field] public String AfterSelectEvent { get; }
        [UsedImplicitly][Field] public Boolean CheckBoxes { get; }
        [UsedImplicitly][Field] public Boolean ShowLines { get; } = true;
        [UsedImplicitly][Field] public Boolean ShowRootLines { get; } = true;
        }
    }
