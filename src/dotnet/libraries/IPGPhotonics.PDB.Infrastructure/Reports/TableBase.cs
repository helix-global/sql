using System;
using System.Collections.Generic;
using System.ComponentModel;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    public abstract class TableBase : BreakableComponent
        {
        [UsedImplicitly][Field] public Boolean AdjustSpannedCellsWidth { get; }
        [UsedImplicitly][Field] public Boolean RepeatHeaders { get; } = true;
        [UsedImplicitly][Field] public Int32 ColumnCount { get; }
        [UsedImplicitly][Field] public Int32 FixedColumns { get; }
        [UsedImplicitly][Field] public Int32 FixedRows { get; }
        [UsedImplicitly][Field] public Int32 RowCount { get; }
        [UsedImplicitly][Field] public TableLayout Layout { get; }
        [UsedImplicitly][Field] public Single WrappedGap { get; }
        }
    }
