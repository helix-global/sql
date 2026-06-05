using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics.CodeAnalysis;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class DataConnectionBase : DataComponentBase
        {
        [UsedImplicitly][Field] public Boolean LoginPrompt { get; }
        [UsedImplicitly][Field][DefaultValue(30)] public Int32 CommandTimeout { get; } = 30;
        [UsedImplicitly][Field] public String ConnectionString { get; }
        [UsedImplicitly][Field] public String ConnectionStringExpression { get; }
        [UsedImplicitly] public IList<TableDataSource> Tables { get; } = new SqlObjectCollection<TableDataSource>();

        public override IEnumerable<FastReportObject> Children { get {
            foreach (var o in Tables) {
                yield return o;
                }
            }}

        #region M:UpdateReferences(IList<FastReportObject>)
        [SuppressMessage("ReSharper", "LocalVariableHidesMember")]
        protected override void UpdateReferences(IList<FastReportObject> source) {
            using (var Tables = PrepareChanges(this.Tables)) {
                foreach (var o in source) {
                    if (o is TableDataSource DataSource) {
                        Tables.Add(DataSource);
                        }
                    }
                }
            }
        #endregion
        }
    }