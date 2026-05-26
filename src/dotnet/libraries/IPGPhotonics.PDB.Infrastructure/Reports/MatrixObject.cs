using System;
using System.Collections.Generic;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("MatrixObject")]
    internal class MatrixObject : TableBase
        {
        [UsedImplicitly][Field(EmptyIfNull = true,Source="MatrixColumns")] public IList<MatrixHeaderDescriptor> Columns { get; }
        [UsedImplicitly][Field(EmptyIfNull = true,Source="MatrixRows")]    public IList<MatrixHeaderDescriptor> Rows { get; }
        [UsedImplicitly][Field(EmptyIfNull = true,Source="MatrixCells")]   public IList<MatrixCellDescriptor>   Cells { get; }
        [UsedImplicitly][Field] public Boolean AutoSize { get; } = true;
        [UsedImplicitly][Field] public Boolean CellsSideBySide { get; }
        [UsedImplicitly][Field] public Boolean KeepCellsSideBySide { get; }
        [UsedImplicitly][Field] public Int32 ColumnIndex { get; }
        [UsedImplicitly][Field] public Int32 RowIndex { get; }
        [UsedImplicitly][Field] public String Filter { get; }
        [UsedImplicitly][Field] public String ManualBuildEvent { get; }
        [UsedImplicitly][Field] public String ModifyResultEvent { get; }
        [UsedImplicitly][Field] public String ShowTitle { get; }
        [UsedImplicitly][Field] public String DataSource { get; }
        [UsedImplicitly][Field] public MatrixEvenStylePriority MatrixEvenStylePriority { get; }
        }
    }
