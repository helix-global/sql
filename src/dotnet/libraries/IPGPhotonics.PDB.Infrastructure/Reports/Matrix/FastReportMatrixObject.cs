using System;
using System.Collections.Generic;
using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("MatrixObject")]
    internal sealed class FastReportMatrixObject : FastReportTableBase
        {
        [UsedImplicitly][Field(Order=1000001,EmptyIfNull = true,Source="MatrixColumns")] public IList<FastReportMatrixHeaderDescriptor> Columns { get; }
        [UsedImplicitly][Field(Order=1000002,EmptyIfNull = true,Source="MatrixRows")]    public IList<FastReportMatrixHeaderDescriptor> Rows { get; }
        [UsedImplicitly][Field(Order=1000003,EmptyIfNull = true,Source="MatrixCells")]   public IList<FastReportMatrixCellDescriptor>   Cells { get; }
        [UsedImplicitly][Field(Order=1000601)][DefaultValue(true)] public Boolean AutoSize { get; } = true;
        [UsedImplicitly][Field(Order=1000602)] public Boolean CellsSideBySide { get; }
        [UsedImplicitly][Field(Order=1000603)] public Boolean KeepCellsSideBySide { get; }
        [UsedImplicitly][Field(Order=1000600)] public Int32 ColumnIndex { get; }
        [UsedImplicitly][Field(Order=1000600)] public Int32 RowIndex { get; }
        [UsedImplicitly][Field(Order=1000605)] public String Filter { get; }
        [UsedImplicitly][Field(Order=1000609)] public String ManualBuildEvent { get; }
        [UsedImplicitly][Field(Order=1000610)] public String ModifyResultEvent { get; }
        [UsedImplicitly][Field(Order=1000606)] public String ShowTitle { get; }
        [UsedImplicitly][Field(Order=1000604)] public String DataSource { get; }
        [UsedImplicitly][Field(Order=1000607)] public override String Style { get; }
        [UsedImplicitly][Field(Order=1000608)] public MatrixEvenStylePriority MatrixEvenStylePriority { get; }

        #region M:Serialize(IFastReportSerializer,String,Object)
        public override void Serialize(IFastReportSerializer serializer,String prefix,Object other) {
            if (serializer == null) { throw new ArgumentNullException(nameof(serializer)); }
            serializer.Serialize(this,prefix,other);
            }
        #endregion
        }
    }
