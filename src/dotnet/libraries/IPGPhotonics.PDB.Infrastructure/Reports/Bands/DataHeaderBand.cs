using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [FastReportClass("DataHeaderBand")]
    internal sealed class DataHeaderBand : HeaderFooterBandBase
        {
        #region M:Accept(IFastReportVisitor)
        public override void Accept(IFastReportVisitor visitor)
            {
            if (visitor == null) { throw new ArgumentNullException(nameof(visitor)); }
            visitor.Visit(this);
            }
        #endregion
        }
    }
