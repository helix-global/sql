using System;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;
using IPGPhotonics.PDB.Infrastructure.Reports;

namespace IPGPhotonics.PDB.Infrastructure
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("ShapeObject")]
    internal sealed class ShapeObject : ReportComponentBase
        {
        protected internal override String ClassName { get { return "ShapeObject"; }}
        [UsedImplicitly][Field] public Single Curve { get; }
        [UsedImplicitly][Field] public ShapeKind Shape { get; }

        #region M:Accept(IFastReportVisitor)
        public override void Accept(IFastReportVisitor visitor)
            {
            throw new NotImplementedException();
            }
        #endregion
        }
    }
