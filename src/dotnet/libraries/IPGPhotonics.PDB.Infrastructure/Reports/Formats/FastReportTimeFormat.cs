using System;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [FastReportClass("TimeFormat")]
    internal sealed class FastReportTimeFormat : FastReportCustomFormat
        {
        #region M:Accept(IFastReportVisitor)
        public override void Accept(IFastReportVisitor visitor) {
            if (visitor == null) { throw new ArgumentNullException(nameof(visitor)); }
            visitor.Visit(this);
            }
        #endregion
        }
    }