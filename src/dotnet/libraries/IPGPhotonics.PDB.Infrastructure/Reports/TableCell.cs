using System;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("TableCell")]
    internal sealed class TableCell : TextObject
        {
        [UsedImplicitly][Field] public Int32 ColSpan { get; } = 1;
        [UsedImplicitly][Field] public Int32 RowSpan { get; } = 1;
        }
    }
