using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection.Emit;
using System.Text;
using System.Threading.Tasks;
using System.Xml;
using BinaryStudio.SqlServer.Infrastructure;
using IPGPhotonics.PDB.Infrastructure.Reports;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace BinaryStudio.TestTools.UnitTesting.IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TestClass]
    public class ReportT
        {
        #region T:[FastReport]:ReadWriteTemplate
        [TestMethod("[FastReport]:ReadWriteTemplate")]
        public void ReadWriteTemplate() {
            var source = File.ReadAllBytes("def_markup_test.frx");
            var report = FastReport.LoadFrom(source);
            Byte[] target;
            using (var stream = new MemoryStream()) {
                using (var writer = new FastReportXmlWriter(stream, new XmlWriterSettings {
                    Indent = true,
                    Encoding = Encoding.UTF8,
                    OmitXmlDeclaration = false,
                    }))
                    {
                    writer.WriteProcessingInstruction("xml","version=\"1.0\" encoding=\"utf-8\"");
                    report.Serialize(writer,null,null);
                    writer.WriteWhitespace(Environment.NewLine);
                    }
                stream.Position = 0;
                target = stream.ToArray();
                }
            File.WriteAllBytes($"def_markup_test.frz",target);
            using (var writer = new SqlXmlWriter("def_markup_test.xml"))
                {
                report.WriteXml(writer);
                }
            }
        #endregion
        }
    }
