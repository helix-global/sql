using System;
using System.ComponentModel;
using System.Xml;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(BarcodeConverter))]
    internal abstract class BarcodeBase : FastReportObject
        {
        #region M:Serialize(XmlWriter,String)
        public override void Serialize(XmlWriter writer,String prefix) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            SerializeAttributes(writer,this,prefix);
            }
        #endregion
        }
    }