using System.IO;
using System.Text;
using System.Xml;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    internal class FastReportXmlWriter : SqlXmlWriter,ILineFeedEntityWriter,ICarriageReturnEntityWriter,ITabEntityWriter
        {
        #region ctor{StringBuilder,XmlWriterSettings}
        public FastReportXmlWriter(StringBuilder builder,XmlWriterSettings settings)
            : base(builder,settings)
            {
            }
        #endregion
        #region ctor{Stream,XmlWriterSettings}
        public FastReportXmlWriter(Stream stream,XmlWriterSettings settings)
            : base(stream,settings)
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
        #region ILineFeedEntityWriter.Write(byte*):byte*
        unsafe byte* ILineFeedEntityWriter.Write(byte* target) {
            target[0] = (byte)'&';
            target[1] = (byte)'#';
            target[2] = (byte)'1';
            target[3] = (byte)'0';
            target[4] = (byte)';';
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
        #region ICarriageReturnEntityWriter.Write(byte*):byte*
        unsafe byte* ICarriageReturnEntityWriter.Write(byte* target) {
            target[0] = (byte)'&';
            target[1] = (byte)'#';
            target[2] = (byte)'1';
            target[3] = (byte)'3';
            target[4] = (byte)';';
            return target + 5;
            }
        #endregion
        #region ITabEntityWriter.Write(char*):char*
        unsafe char* ITabEntityWriter.Write(char* target) {
            target[0] = '\t';
            return target + 1;
            }
        #endregion
        #region ITabEntityWriter.Write(byte*):byte*
        unsafe byte* ITabEntityWriter.Write(byte* target) {
            target[0] = (byte)'\t';
            return target + 1;
            }
        #endregion
        }
    }
