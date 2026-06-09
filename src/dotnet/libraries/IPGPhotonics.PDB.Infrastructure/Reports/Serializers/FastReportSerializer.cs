using System;
using System.Xml;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    internal class FastReportSerializer
        {
        #region ctor{XmlWriter}
        public FastReportSerializer(XmlWriter writer)
            {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            m_writer = writer;
            }
        #endregion

        #region M:Visit(FastReport)
        public void Visit(FastReport o) {
            if (o == null) { throw new ArgumentNullException(nameof(o)); }
            o.Serialize(m_writer,null);
            }
        #endregion

        private readonly XmlWriter m_writer;
        }
    }
