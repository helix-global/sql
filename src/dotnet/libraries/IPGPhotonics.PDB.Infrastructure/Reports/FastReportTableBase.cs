using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics.CodeAnalysis;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class FastReportTableBase : FastReportBreakableComponent
        {
        [UsedImplicitly][Field(Order=1000506)] public Boolean AdjustSpannedCellsWidth { get; }
        [UsedImplicitly][Field(Order=1000503)][DefaultValue(true)] public Boolean RepeatHeaders { get; } = true;
        [UsedImplicitly][Field(Order=1000500)] public Int32 ColumnCount { get; }
        [UsedImplicitly][Field(Order=1000502)] public Int32 FixedColumns { get; }
        [UsedImplicitly][Field(Order=1000501)] public Int32 FixedRows { get; }
        [UsedImplicitly][Field(Order=1000500)] public Int32 RowCount { get; }
        [UsedImplicitly][Field(Order=1000504)] public TableLayout Layout { get; }
        [UsedImplicitly][Field(Order=1000505,ConverterCulture="en-US")] public Single WrappedGap { get; }
        public IList<FastReportTableColumn> Columns { get; } = new SqlObjectCollection<FastReportTableColumn>();
        public IList<FastReportTableRow> Rows { get; } = new SqlObjectCollection<FastReportTableRow>();
        public override IEnumerable<FastReportObject> Children { get {
            foreach (var o in Columns) {
                yield return o;
                }
            foreach (var o in Rows) {
                yield return o;
                }
            }}

        #region M:UpdateReferences(IList<FastReportObject>)
        [SuppressMessage("ReSharper", "LocalVariableHidesMember")]
        protected override void UpdateReferences(IList<FastReportObject> source) {
            using (var Rows = PrepareChanges(this.Rows))
            using (var Columns = PrepareChanges(this.Columns)) {
                foreach (var o in source) {
                    if (o is FastReportTableColumn TableColumn) { Columns.Add(TableColumn); }
                    if (o is FastReportTableRow TableRow) { Rows.Add(TableRow); }
                    }
                }
            }
        #endregion
        }
    }
