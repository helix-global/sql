using System;
using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    internal interface IFastReportCustomSerializer
        {
        void Serialize(ISqlXmlWriter writer,Object source,PropertyDescriptor descriptor);
        }

    internal abstract class FastReportCustomSerializer : IFastReportCustomSerializer
        {
        protected abstract void Serialize(ISqlXmlWriter writer,Object source,PropertyDescriptor descriptor);

        #region M:IFastReportCustomSerializer.Serialize(ISqlXmlWriter,Object,PropertyDescriptor)
        void IFastReportCustomSerializer.Serialize(ISqlXmlWriter writer,Object source,PropertyDescriptor descriptor)
            {
            Serialize(writer,source,descriptor);
            }
        #endregion
        }
    }
