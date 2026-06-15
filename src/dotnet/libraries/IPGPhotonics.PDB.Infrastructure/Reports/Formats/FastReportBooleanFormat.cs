using System;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    internal sealed class FastReportBooleanFormat : FastReportFormatBase
        {
        #region M:Accept(IFastReportVisitor)
        public override void Accept(IFastReportVisitor visitor) {
            if (visitor == null) { throw new ArgumentNullException(nameof(visitor)); }
            visitor.Visit(this);
            }
        #endregion
        }
    }