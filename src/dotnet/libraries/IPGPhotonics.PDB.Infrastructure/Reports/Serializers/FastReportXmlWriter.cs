using System.Text;
using System.Xml;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    internal class FastReportXmlWriter : SqlXmlWriter,ILineFeedEntityWriter,ICarriageReturnEntityWriter
        {
        #region ctor{StringBuilder,XmlWriterSettings}
        public FastReportXmlWriter(StringBuilder builder,XmlWriterSettings settings)
            : base(builder,settings)
            {
            }
        #endregion
        #region ILineFeedEntityWriter.Write(char*):char*
        unsafe char* ILineFeedEntityWriter.Write(char* target) {
            target[0] = '&';
            target[1] = '#';
            target[2] = '1';
            target[3] = '0';
            target[4] = ';';
            return target + 5;
            }
        #endregion
        #region ICarriageReturnEntityWriter.Write(char*):char*
        unsafe char* ICarriageReturnEntityWriter.Write(char* target) {
            target[0] = '&';
            target[1] = '#';
            target[2] = '1';
            target[3] = '3';
            target[4] = ';';
            return target + 5;
            }
        #endregion
        }
    }
