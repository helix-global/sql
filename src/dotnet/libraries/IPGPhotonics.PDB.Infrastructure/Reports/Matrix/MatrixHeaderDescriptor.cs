using System;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("Header")]
    internal sealed class MatrixHeaderDescriptor : MatrixDescriptor
        {
        [UsedImplicitly][Field] public Boolean PageBreak { get; }
        [UsedImplicitly][Field] public Boolean SuppressTotals { get; }
        [UsedImplicitly][Field] public Boolean Totals { get; }
        [UsedImplicitly][Field] public Boolean TotalsFirst { get; }
        [UsedImplicitly][Field] public SortOrder Sort { get; }

        #region M:Accept(IFastReportVisitor)
        public override void Accept(IFastReportVisitor visitor)
            {
            throw new NotImplementedException();
            }
        #endregion
        }
    }