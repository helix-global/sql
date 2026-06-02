using System;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal sealed class BandColumns : FastReportObject
        {
        [UsedImplicitly][Field] public Int32 Count { get; }
        [UsedImplicitly][Field] public Int32 MinRowCount { get; }
        [UsedImplicitly][Field] public ColumnLayout Layout { get; }
        [UsedImplicitly][Field] public Single Width { get; }

        #region M:Accept(IFastReportVisitor)
        public override void Accept(IFastReportVisitor visitor)
            {
            if (visitor == null) { throw new ArgumentNullException(nameof(visitor)); }
            visitor.Visit(this);
            }
        #endregion
        }
    }