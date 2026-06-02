using System;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    internal class ShapePolygon : ShapeBase
        {
        protected internal override String ClassName { get { return "ShapePolygon"; }}
        #region M:Accept(IFastReportVisitor)
        public override void Accept(IFastReportVisitor visitor)
            {
            throw new NotImplementedException();
            }
        #endregion
        }
    }