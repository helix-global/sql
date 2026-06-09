using System;
using System.ComponentModel;
using System.Windows.Forms;
using System.Xml;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    internal class DataGridViewCellStyleSerializer : FastReportSerializer
        {
        private static void SerializeIfDifferent<T>(XmlWriter writer,String prefix,String name,T value,T other) {
            if (!Equals(value,other)) {
                writer.WriteAttributeString($"{prefix}.{name}",
                    TypeDescriptor.GetConverter(value).ConvertToInvariantString(value));
                }
            }
        #region M:Serialize(XmlWriter,Object,PropertyDescriptor)
        protected override void Serialize(XmlWriter writer,Object source,PropertyDescriptor descriptor) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            if (descriptor == null) { throw new ArgumentNullException(nameof(descriptor)); }
            if (source != null) {
                var r = (DataGridViewCellStyle)descriptor.GetValue(source);
                var o = new DataGridViewCellStyle();
                var prefix = descriptor.Name;
                SerializeIfDifferent(writer,prefix,"Alignment",r.Alignment,o.Alignment);
                SerializeIfDifferent(writer,prefix,"BackColor",r.BackColor,o.BackColor);
                if (r.Font != null)
                    {
                    SerializeIfDifferent(writer,prefix,"Font",r.Font,o.Font);
                    }
                SerializeIfDifferent(writer,prefix,"ForeColor",r.ForeColor,o.ForeColor);
                SerializeIfDifferent(writer,prefix,"Format",r.Format,o.Format);
                SerializeIfDifferent(writer,prefix,"NullValue",r.NullValue,o.NullValue);
                SerializeIfDifferent(writer,prefix,"Padding",r.Padding,o.Padding);
                SerializeIfDifferent(writer,prefix,"SelectionBackColor",r.SelectionBackColor,o.SelectionBackColor);
                SerializeIfDifferent(writer,prefix,"SelectionForeColor",r.SelectionForeColor,o.SelectionForeColor);
                SerializeIfDifferent(writer,prefix,"WrapMode",r.WrapMode,o.WrapMode);
                return;
                }
            }
        #endregion
        }
    }
