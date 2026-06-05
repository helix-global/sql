using System;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class TableBase : BreakableComponent
        {
        [UsedImplicitly][Field] public Boolean AdjustSpannedCellsWidth { get; }
        [UsedImplicitly][Field] public Boolean RepeatHeaders { get; } = true;
        [UsedImplicitly][Field] public Int32 ColumnCount { get; }
        [UsedImplicitly][Field] public Int32 FixedColumns { get; }
        [UsedImplicitly][Field] public Int32 FixedRows { get; }
        [UsedImplicitly][Field] public Int32 RowCount { get; }
        [UsedImplicitly][Field] public TableLayout Layout { get; }
        [UsedImplicitly][Field(ConverterCulture="en-US")] public Single WrappedGap { get; }
        }
    }
