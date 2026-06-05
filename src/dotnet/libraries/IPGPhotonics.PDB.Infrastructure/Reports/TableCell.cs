using System;
using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("TableCell")]
    internal sealed class TableCell : TextObject
        {
        [UsedImplicitly][Field(Order=1000701)][DefaultValue(1)] public Int32 ColSpan { get; } = 1;
        [UsedImplicitly][Field(Order=1000702)][DefaultValue(1)] public Int32 RowSpan { get; } = 1;
        }
    }
