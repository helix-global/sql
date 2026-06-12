using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics.CodeAnalysis;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("Column")]
    internal class FastReportColumn : FastReportDataComponentBase
        {
        [UsedImplicitly][Field(Order=1000306)][DefaultValue(false)] public Boolean Calculated { get; }
        [UsedImplicitly][Field(Order=1000301)] public String DataType { get; }
        [UsedImplicitly][Field(Order=1000303)] public String BindableControl { get; }
        [UsedImplicitly][Field(Order=1000304)] public String CustomBindableControl { get; }
        [UsedImplicitly][Field(Order=1000307)] public String Expression { get; }
        [UsedImplicitly][Field(Order=1000302)] public String PropName { get; }
        [UsedImplicitly][Field(Order=1000305)][DefaultValue(ColumnFormat.Auto)] public ColumnFormat Format { get; }
        [UsedImplicitly] public IList<FastReportColumn> Columns { get; } = new SqlObjectCollection<FastReportColumn>();

        public override IEnumerable<FastReportObject> Children { get {
            foreach (var o in Columns) {
                yield return o;
                }
            }}

        #region M:UpdateReferences(IList<FastReportObject>)
        [SuppressMessage("ReSharper", "LocalVariableHidesMember")]
        protected override void UpdateReferences(IList<FastReportObject> source) {
            using (var Columns = PrepareChanges(this.Columns)) {
                foreach (var o in source) {
                    if (o is FastReportColumn Column) {
                        Columns.Add(Column);
                        }
                    }
                }
            }
        #endregion
        }
    }