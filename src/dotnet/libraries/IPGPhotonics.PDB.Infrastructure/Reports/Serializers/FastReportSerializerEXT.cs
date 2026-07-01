using System;
using System.IO;
using System.Linq;
using System.Text;
using System.Windows.Forms.DataVisualization.Charting;
using System.Xml;
using System.Xml.Linq;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    internal class FastReportSerializerEXT : FastReportSerializerSTD,IFastReportSerializer
        {
        #region ctor{ISqlXmlWriter}
        public FastReportSerializerEXT(ISqlXmlWriter writer)
            : base(writer)
            {
            }
        #endregion

        #region M:Serialize(FastReport)
        public override void Serialize(FastReport source)
            {
            source.Serialize(this,null,null);
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReport,String,Object)
        void IFastReportSerializer.Serialize(FastReport source,String prefix,Object other) {
            var ClassName = "Report";
            using (writer.ElementGroup(ClassName)) {
                SerializeAttributes(source, prefix, (descriptor) => {
                    return descriptor.Name != "ReferencedAssemblies";
                    });
                if (!IsNullOrEmpty(source.ReferencedAssemblies)) {
                    writer.WriteCData($"{ClassName}.ReferencedAssemblies",source.ReferencedAssemblies);
                    }
                if (!String.IsNullOrWhiteSpace(source.Script)) {
                    writer.WriteCData($"{ClassName}.Script",source.Script);
                    }
                if (source.Styles.Any()) {
                    using (writer.ElementGroup("Styles")) {
                        Serialize(source.Styles,prefix);
                        }
                    }
                using (writer.ElementGroup("Dictionary")) {
                    Serialize(source.DataSources,prefix);
                    Serialize(source.Relations,prefix);
                    Serialize(source.Parameters,prefix);
                    Serialize(source.Totals,prefix);
                    }
                Serialize(source.Children,prefix);
                }
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportChartObject,String,Object)
        void IFastReportSerializer.Serialize(FastReportChartObject source,String prefix,Object other)
            {
            var ClassName = ((IFastReportClassObjectLegacy)source).ClassName;
            using (writer.ElementGroup(ClassName)) {
                SerializeAttributes(source,prefix,(descriptor)=>
                    !String.Equals(descriptor.Name,"Chart"));
                if (source.Chart != null) {
                    var content = XDocument.Load(new MemoryStream(source.Chart));
                    writer.WriteNode(content.CreateReader(), (ns) => {
                        if (!String.IsNullOrEmpty(ns)) { return ns; }
                        return "urn:schemas.microsoft.com:charting";
                        });
                    }
                Serialize(source.Children,prefix);
                }
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportPictureObject,String,Object)
        void IFastReportSerializer.Serialize(FastReportPictureObject source,String prefix,Object other) {
            var ClassName = ((IFastReportClassObjectLegacy)source).ClassName;
            using (writer.ElementGroup(ClassName)) {
                SerializeAttributes(source,prefix,(descriptor)=>
                    !String.Equals(descriptor.Name,"Image"));
                if (source.Image != null) {
                    writer.WriteBase64($"{ClassName}.Image",source.Image);
                    }
                Serialize(source.Children,prefix);
                }
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportTableDataSource,String,Object)
        void IFastReportSerializer.Serialize(FastReportTableDataSource source,String prefix,Object other) {
            var ClassName = ((IFastReportClassObjectLegacy)source).ClassName;
            using (writer.ElementGroup(ClassName)) {
                SerializeAttributes(source,prefix,(descriptor)=>
                    !String.Equals(descriptor.Name,"SelectCommand"));
                if (!String.IsNullOrWhiteSpace(source.SelectCommand)) {
                    writer.WriteCData($"{ClassName}.SelectCommand",source.SelectCommand);
                    }
                Serialize(source.Children,prefix);
                }
            }
        #endregion
        }
    }
