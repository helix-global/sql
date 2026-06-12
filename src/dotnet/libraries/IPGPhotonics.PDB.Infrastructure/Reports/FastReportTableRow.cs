using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics.CodeAnalysis;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;

    [FastReportClass("TableRow")]
    internal sealed class FastReportTableRow : ComponentBase
        {
        public const Single DefaultHeight = 18.9f;
        [UsedImplicitly][Field(Order=1000304)] public Boolean AutoSize { get; }
        [UsedImplicitly][Field(Order=1000302,ConverterCulture="en-US")][DefaultValue(500f)] public Single MaxHeight { get; } = 500f;
        [UsedImplicitly][Field(Order=1000301,ConverterCulture="en-US")] public Single MinHeight { get; }
        [UsedImplicitly][Field(Order=1000303,ConverterCulture="en-US")][DefaultValue(DefaultHeight)] public override Single Height { get; } = DefaultHeight;
        public IList<FastReportTableCell> Cells { get; } = new SqlObjectCollection<FastReportTableCell>();
        public override IEnumerable<FastReportObject> Children { get {
            foreach (var o in Cells) {
                yield return o;
                }
            }}

        #region M:UpdateReferences(IList<FastReportObject>)
        [SuppressMessage("ReSharper", "LocalVariableHidesMember")]
        protected override void UpdateReferences(IList<FastReportObject> source) {
            using (var Cells = PrepareChanges(this.Cells)) {
                foreach (var o in source) {
                    if (o is FastReportTableCell TableCell) { Cells.Add(TableCell); }
                    }
                }
            }
        #endregion
        }
    }
