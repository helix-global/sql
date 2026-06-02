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
    internal class Column : DataComponentBase
        {
        [UsedImplicitly][Field(Order=1000360)][DefaultValue(false)] public Boolean Calculated { get; }
        [UsedImplicitly][Field(Order=1000310)] public String DataType { get; }
        [UsedImplicitly][Field(Order=1000330)] public String BindableControl { get; }
        [UsedImplicitly][Field(Order=1000340)] public String CustomBindableControl { get; }
        [UsedImplicitly][Field(Order=1000370)] public String Expression { get; }
        [UsedImplicitly][Field(Order=1000320)] public String PropName { get; }
        [UsedImplicitly][Field(Order=1000350)][DefaultValue(ColumnFormat.Auto)] public ColumnFormat Format { get; }
        [UsedImplicitly] public IList<Column> Columns { get; } = new SqlObjectCollection<Column>();

        public override IEnumerable<FastReportObject> Children { get {
            foreach (var o in Columns) {
                yield return o;
                }
            }}

        #region M:Accept(IFastReportVisitor)
        public override void Accept(IFastReportVisitor visitor)
            {
            if (visitor == null) { throw new ArgumentNullException(nameof(visitor)); }
            visitor.Visit(this);
            }
        #endregion
        #region M:UpdateReferences(IList<FastReportObject>)
        [SuppressMessage("ReSharper", "LocalVariableHidesMember")]
        protected override void UpdateReferences(IList<FastReportObject> source) {
            using (var Columns = PrepareChanges(this.Columns)) {
                foreach (var o in source) {
                    if (o is Column Column) {
                        Columns.Add(Column);
                        }
                    }
                }
            }
        #endregion
        }
    }