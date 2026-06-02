using IPGPhotonics.PDB.Infrastructure.Reports;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IPGPhotonics.PDB.Infrastructure
    {
    internal sealed class CrossBandObject : ReportComponentBase
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
