using System;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [FastReportClass("GeneralFormat")]
    internal sealed class FastReportGeneralFormat : FastReportFormatBase
        {
        #region M:Accept(IFastReportVisitor)
        public override void Accept(IFastReportVisitor visitor) {
            if (visitor == null) { throw new ArgumentNullException(nameof(visitor)); }
            visitor.Visit(this);
            }
        #endregion
        }
    }