using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    internal sealed class ZipCodeObject : ReportComponentBase
        {
        protected internal override String ClassName { get { return "ZipCodeObject"; }}

        #region M:Accept(IFastReportVisitor)
        public override void Accept(IFastReportVisitor visitor)
            {
            throw new NotImplementedException();
            }
        #endregion
        }
    }
