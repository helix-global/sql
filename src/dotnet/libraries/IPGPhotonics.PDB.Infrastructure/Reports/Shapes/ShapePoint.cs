using System;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    internal sealed class ShapePoint : ShapeBase
        {
        protected internal override String ClassName { get { return "ShapePoint"; }}
        #region M:Accept(IFastReportVisitor)
        public override void Accept(IFastReportVisitor visitor)
            {
            throw new NotImplementedException();
            }
        #endregion
        }
    }