using System;
using System.Xml;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal static class XmlWriterExtensions
        {
        #region M:ElementGroup({this}XmlWriter,String,String,String):IDisposable
        public static IDisposable ElementGroup(this XmlWriter writer,String prefix, String localName, String ns)
            {
            return new ElementGroupScope(writer,prefix,localName,ns);
            }
        #endregion
        #region M:ElementGroup({this}XmlWriter,String,String):IDisposable
        public static IDisposable ElementGroup(this XmlWriter writer,String localName,String ns)
            {
            return new ElementGroupScope(writer,localName,ns);
            }
        #endregion
        #region M:ElementGroup({this}XmlWriter,String):IDisposable
        public static IDisposable ElementGroup(this XmlWriter writer,String localName)
            {
            return new ElementGroupScope(writer,localName);
            }
        #endregion
        #region M:WriteAttribute({this}XmlWriter,String,Object)
        public static void WriteAttribute(this XmlWriter writer,String localName,Object value) {
            WriteAttribute(writer,false,localName,value);
            }
        #endregion
        #region M:WriteAttribute({this}XmlWriter,Boolean,String,Object)
        public static void WriteAttribute(this XmlWriter writer,Boolean NewLine,String localName,Object value) {
            if ((value == null) || (value is DBNull)) { return; }
            //if (writer is ISqlXmlWriter o)
            //    {
            //    o.WriteAttribute(NewLine,localName,value);
            //    }
            //else
                {
                     if (value is DateTime DT) { value = DT.ToString("s");   }
                else if (value is Guid GUID)   { value = GUID.ToString("B"); }
                writer.WriteAttributeString(localName, value.ToString());
                }
            }
        #endregion
        #region M:WriteCDATA({this}XmlWriter,String,CDATA)
        public static void WriteCDATA(this XmlWriter writer,String localName,CDATA value) {
            if (value == null) { return; }
            using (writer.ElementGroup(localName)) {
                writer.WriteCData(value.ToString());
                }
            }
        #endregion
        #region M:WriteCDATA({this}XmlWriter,String,String,CDATA)
        public static void WriteCDATA(this XmlWriter writer,String localName,String ns,CDATA value) {
            if (value == null) { return; }
            using (writer.ElementGroup(localName,ns)) {
                writer.WriteCData(value.ToString());
                }
            }
        #endregion

        private class ElementGroupScope: IDisposable
            {
            private XmlWriter writer;

            #region ctor{XmlWriter}
            private ElementGroupScope(XmlWriter writer)
                {
                this.writer = writer;
                }
            #endregion
            #region ctor{XmlWriter,String,String,String}
            public ElementGroupScope(XmlWriter writer,String prefix, String localName, String ns)
                :this(writer)
                {
                writer.WriteStartElement(prefix,localName,ns);
                }
            #endregion
            #region ctor{XmlWriter,String,String}
            public ElementGroupScope(XmlWriter writer,String localName, String ns)
                :this(writer)
                {
                writer.WriteStartElement(localName,ns);
                }
            #endregion
            #region ctor{XmlWriter,String}
            public ElementGroupScope(XmlWriter writer,String localName)
                :this(writer)
                {
                writer.WriteStartElement(localName);
                }
            #endregion

            public void Dispose() {
                writer.WriteEndElement();
                writer = null;
                }
            }
        }
    }
