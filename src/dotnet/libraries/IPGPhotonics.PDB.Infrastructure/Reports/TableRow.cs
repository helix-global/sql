using System;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;

    [FastReportClass("TableRow")]
    internal sealed class TableRow : ComponentBase
        {
        protected internal override String ClassName { get { return "TableRow"; }}
        [UsedImplicitly][Field] public Boolean AutoSize { get; }
        [UsedImplicitly][Field] public Boolean KeepRows { get; }
        [UsedImplicitly][Field] public Boolean PageBreak { get; }
        [UsedImplicitly][Field] public Single MaxHeight { get; } = 500f;
        [UsedImplicitly][Field] public Single MinHeight { get; }

        #region M:Accept(IFastReportVisitor)
        public override void Accept(IFastReportVisitor visitor)
            {
            throw new NotImplementedException();
            }
        #endregion
        }
    }
