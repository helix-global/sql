using System;
using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("TableDataSource")]
    internal sealed class FastReportTableDataSource : FastReportDataSourceBase
        {
        [UsedImplicitly][Field(Order=1000520)] public String SelectCommand { get; }
        [UsedImplicitly][Field(Order=1000510)] public String TableName { get; }
        [UsedImplicitly][Field(Order=1000530)] public String QbSchema { get; }
        [UsedImplicitly][Field(Order=1000540)] public Boolean StoreData { get; }
        [UsedImplicitly] public IList<FastReportCommandParameter> Parameters { get; } = new SqlObjectCollection<FastReportCommandParameter>();

        public override IEnumerable<FastReportObject> Children { get {
            foreach (var o in base.Children) {
                yield return o;
                }
            foreach (var o in Parameters) {
                yield return o;
                }
            }}

        #region M:UpdateReferences(IList<FastReportObject>)
        [SuppressMessage("ReSharper", "LocalVariableHidesMember")]
        protected override void UpdateReferences(IList<FastReportObject> source) {
            base.UpdateReferences(source);
            using (var Parameters = PrepareChanges(this.Parameters)) {
                foreach (var o in source) {
                    if (o is FastReportCommandParameter CommandParameter) {
                        Parameters.Add(CommandParameter);
                        }
                    }
                }
            }
        #endregion
        }
    }