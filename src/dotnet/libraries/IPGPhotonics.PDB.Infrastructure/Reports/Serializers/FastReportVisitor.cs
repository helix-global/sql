using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    internal abstract class FastReportVisitor : IFastReportVisitor
        {
        #region M:Visit<T>(IEnumerable<T>)
        protected void Visit<T>(IEnumerable<T> objects)
            where T: FastReportObject
            {
            foreach (var o in objects)
                {
                o.Accept(this);
                }
            }
        #endregion

        #region M:Visit(FastReport)
        public virtual void Visit(FastReport o)
            {
            if (o == null) { throw new ArgumentNullException(nameof(o)); }
            Visit(o.Children);
            }
        #endregion
        }
    }
