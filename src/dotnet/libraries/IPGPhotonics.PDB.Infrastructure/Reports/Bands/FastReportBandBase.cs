using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics.CodeAnalysis;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class FastReportBandBase : FastReportBreakableComponent
        {
        [UsedImplicitly][Field(Order=1000502)] public Boolean FirstRowStartsNewPage { get; }
        [UsedImplicitly][Field(Order=1000504)] public Boolean KeepChild { get; }
        [UsedImplicitly][Field(Order=1000503)] public Boolean PrintOnBottom { get; }
        [UsedImplicitly][Field(Order=1000501)] public Boolean StartNewPage { get; }
        [UsedImplicitly][Field(Order=1000506,Converter=typeof(SqlSingleCollectionConverter))] public IList<Single> Guides { get; }
        [UsedImplicitly][Field(Order=1000505)] public String OutlineExpression { get; }
        [UsedImplicitly][Field(Order=1000508)] public String AfterLayoutEvent { get; }
        [UsedImplicitly][Field(Order=1000507)] public String BeforeLayoutEvent { get; }
        [UsedImplicitly][Field(Order=1000400)][DefaultValue(false)] public override Boolean CanBreak { get; }
        public IList<ReportComponentBase> Objects { get; } = new SqlObjectCollection<ReportComponentBase>();
        public override IEnumerable<FastReportObject> Children { get {
            foreach (var o in Objects) {
                yield return o;
                }
            }}

        #region M:UpdateReferences(IList<FastReportObject>)
        [SuppressMessage("ReSharper", "LocalVariableHidesMember")]
        protected override void UpdateReferences(IList<FastReportObject> source) {
            using (var Objects = PrepareChanges(this.Objects)) {
                foreach (var o in source) {
                    if (o is ReportComponentBase ReportComponentBase) {
                        Objects.Add(ReportComponentBase);
                        }
                    }
                }
            }
        #endregion
        }
    }
