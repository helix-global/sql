using System;
using System.ComponentModel;
using System.Xml;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    internal interface IFastReportCustomSerializer
        {
        void Serialize(XmlWriter writer,Object source,PropertyDescriptor descriptor);
        }

    internal abstract class FastReportCustomSerializer : IFastReportCustomSerializer
        {
        protected abstract void Serialize(XmlWriter writer,Object source,PropertyDescriptor descriptor);

        #region M:IFastReportCustomSerializer.Serialize(XmlWriter,Object,PropertyDescriptor)
        void IFastReportCustomSerializer.Serialize(XmlWriter writer,Object source,PropertyDescriptor descriptor)
            {
            Serialize(writer,source,descriptor);
            }
        #endregion
        }
    }
