using System;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [FastReportClass("GeneralFormat")]
    internal sealed class GeneralFormat : FormatBase
        {
        #region M:Accept(IFastReportVisitor)
        public override void Accept(IFastReportVisitor visitor)
            {
            throw new NotImplementedException();
            }
        #endregion
        }
    }