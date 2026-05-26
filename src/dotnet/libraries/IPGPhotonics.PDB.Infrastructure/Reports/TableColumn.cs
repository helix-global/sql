using System;
using System.Collections.Generic;
using System.ComponentModel;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("TableColumn")]
    internal sealed class TableColumn : ComponentBase
        {
        [UsedImplicitly][Field] public Boolean AutoSize { get; }
        [UsedImplicitly][Field] public Boolean PageBreak { get; }
        [UsedImplicitly][Field] public Int32 KeepColumns { get; }
        [UsedImplicitly][Field] public Single MaxWidth { get; } = 500f;
        [UsedImplicitly][Field] public Single MinWidth { get; }
        }
    }
