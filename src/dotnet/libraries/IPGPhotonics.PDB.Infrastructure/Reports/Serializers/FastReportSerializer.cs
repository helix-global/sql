using System;
using System.ComponentModel;
using System.Xml;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    internal interface IFastReportSerializer
        {
        void Serialize(XmlWriter writer,Object source,PropertyDescriptor descriptor);
        }

    internal abstract class FastReportSerializer : IFastReportSerializer
        {
        protected abstract void Serialize(XmlWriter writer,Object source,PropertyDescriptor descriptor);

        #region M:IFastReportSerializer.Serialize(XmlWriter,Object,PropertyDescriptor)
        void IFastReportSerializer.Serialize(XmlWriter writer,Object source,PropertyDescriptor descriptor)
            {
            Serialize(writer,source,descriptor);
            }
        #endregion
        }
    }
