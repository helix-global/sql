using System;
using System.IO;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Xml;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public class SqlXmlWriter : XmlWriter,ISqlXmlWriter
        {
        public override WriteState WriteState { get { return writer.WriteState; }}

        #region ctor{TextWriter}
        public SqlXmlWriter(TextWriter writer) {
            this.writer = new InternalXmlWriter(writer);
            }
        #endregion
        #region ctor{StringBuilder}
        public SqlXmlWriter(StringBuilder builder) {
            writer = new InternalXmlWriter(builder);
            }
        #endregion
        #region ctor{StringBuilder,XmlWriterSettings}
        public SqlXmlWriter(StringBuilder builder,XmlWriterSettings settings) {
            writer = new InternalXmlWriter(builder,settings);
            }
        #endregion
        #region ctor{XmlWriter}
        public SqlXmlWriter(XmlWriter writer)
            :this(writer,false)
            {
            }
        #endregion
        #region ctor{XmlWriter,Boolean}
        public SqlXmlWriter(XmlWriter writer,Boolean LeaveOpen) {
            this.LeaveOpen = LeaveOpen;
            this.writer = new InternalXmlWriter(writer);
            }
        #endregion

        private class InternalXmlWriter : XmlWriter
            {
            public String LocalName { get;set; }
            public String NamespaceURI { get;set; }
            public String Prefix { get;set; }

            private XmlWriter writer,InnerWriter;
            private MethodInfo WriteIndentMethod;

            private void Update() {
                var typeN = writer.GetType();
                if (typeN.Name == "XmlWellFormedWriter") {
                    var propI = typeN.GetProperty("InnerWriter",BindingFlags.Instance|BindingFlags.NonPublic);
                    InnerWriter = propI.GetValue(writer,null) as XmlWriter;
                    var typeI = InnerWriter?.GetType();
                    if ((typeI != null) && (
                        (typeI.Name == "XmlEncodedRawTextWriterIndent") ||
                        (typeI.Name == "XmlUtf8RawTextWriterIndent")))
                        {
                        WriteIndentMethod = typeI.GetMethod("WriteIndent",BindingFlags.Instance|BindingFlags.NonPublic);
                        }
                    }
                }

            #region ctor{XmlWriter}
            public InternalXmlWriter(XmlWriter writer) {
                if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
                this.writer = writer;
                Update();
                }
            #endregion
            #region ctor{TextWriter}
            public InternalXmlWriter(TextWriter writer) {
                if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
                this.writer = Create(writer,new XmlWriterSettings{
                    Indent = true,
                    IndentChars = "  ",
                    NewLineHandling = NewLineHandling.None,
                    OmitXmlDeclaration = true
                    });
                Update();
                }
            #endregion
            #region ctor{StringBuilder}
            public InternalXmlWriter(StringBuilder builder) {
                if (builder == null) { throw new ArgumentNullException(nameof(builder)); }
                this.writer = Create(builder,new XmlWriterSettings{
                    Indent = true,
                    IndentChars = "  ",
                    NewLineHandling = NewLineHandling.None,
                    OmitXmlDeclaration = true
                    });
                Update();
                }
            #endregion
            #region ctor{StringBuilder,XmlWriterSettings}
            public InternalXmlWriter(StringBuilder builder,XmlWriterSettings settings) {
                if (builder == null) { throw new ArgumentNullException(nameof(builder)); }
                this.writer = Create(builder,settings);
                Update();
                }
            #endregion

            private XmlWriter WriteIndent(XmlWriter writer) {
                if (WriteIndentMethod != null) {
                    WriteIndentMethod.Invoke(InnerWriter,null);
                    }
                return writer;
                }

            #region M:WriteAttribute(Boolean,String,Object)
            public void WriteAttribute(Boolean newline,String localName,Object value) {
                if ((value == null) || (value is DBNull)) { return; }
                     if (value is DateTime DT) { value = DT.ToString("s");   }
                else if (value is Guid GUID)   { value = GUID.ToString("B"); }
                if (newline) {
                    WriteIndent(writer);
                    InnerWriter.WriteWhitespace(new String(' ',LocalName.Length));
                    }
                writer.WriteAttributeString(localName, value.ToString());
                }
            #endregion
            #region M:WriteStartDocument
            /// <summary>When overridden in a derived class, writes the XML declaration with the version "1.0".</summary>
            /// <exception cref="T:System.InvalidOperationException">This is not the first write method called after the constructor.</exception>
            /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
            public override void WriteStartDocument()
                {
                writer.WriteStartDocument();
                }
            #endregion
            #region M:WriteStartDocument(Boolean)
            /// <summary>When overridden in a derived class, writes the XML declaration with the version "1.0" and the standalone attribute.</summary>
            /// <param name="standalone">If <see langword="true"/>, it writes "standalone=yes"; if <see langword="false"/>, it writes "standalone=no".</param>
            /// <exception cref="T:System.InvalidOperationException">This is not the first write method called after the constructor.</exception>
            /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
            public override void WriteStartDocument(Boolean standalone)
                {
                writer.WriteStartDocument(standalone);
                }
            #endregion
            #region M:WriteEndDocument
            /// <summary>When overridden in a derived class, closes any open elements or attributes and puts the writer back in the Start state.</summary>
            /// <exception cref="T:System.ArgumentException">The XML document is invalid.</exception>
            /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
            public override void WriteEndDocument()
                {
                writer.WriteEndDocument();
                }
            #endregion
            #region M:WriteDocType(String,String,String,String)
            /// <summary>When overridden in a derived class, writes the DOCTYPE declaration with the specified name and optional attributes.</summary>
            /// <param name="name">The name of the DOCTYPE. This must be non-empty.</param>
            /// <param name="pubid">If non-null it also writes PUBLIC "pubid" "sysid" where <paramref name="pubid"/> and <paramref name="sysid"/> are replaced with the value of the given arguments.</param>
            /// <param name="sysid">If <paramref name="pubid"/> is <see langword="null"/> and <paramref name="sysid"/> is non-null it writes SYSTEM "sysid" where <paramref name="sysid"/> is replaced with the value of this argument.</param>
            /// <param name="subset">If non-null it writes [subset] where subset is replaced with the value of this argument.</param>
            /// <exception cref="T:System.InvalidOperationException">This method was called outside the prolog (after the root element).</exception>
            /// <exception cref="T:System.ArgumentException">The value for <paramref name="name"/> would result in invalid XML.</exception>
            /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
            public override void WriteDocType(String name, String pubid, String sysid, String subset)
                {
                writer.WriteDocType(name,pubid,sysid,subset);
                }
            #endregion
            #region M:WriteStartElement(String,String,String)
            /// <summary>When overridden in a derived class, writes the specified start tag and associates it with the given namespace and prefix.</summary>
            /// <param name="prefix">The namespace prefix of the element.</param>
            /// <param name="localName">The local name of the element.</param>
            /// <param name="ns">The namespace URI to associate with the element.</param>
            /// <exception cref="T:System.InvalidOperationException">The writer is closed.</exception>
            /// <exception cref="T:System.Text.EncoderFallbackException">There is a character in the buffer that is a valid XML character but is not valid for the output encoding. For example, if the output encoding is ASCII, you should only use characters from the range of 0 to 127 for element and attribute names. The invalid character might be in the argument of this method or in an argument of previous methods that were writing to the buffer. Such characters are escaped by character entity references when possible (for example, in text nodes or attribute values). However, the character entity reference is not allowed in element and attribute names, comments, processing instructions, or CDATA sections.</exception>
            /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
            public override void WriteStartElement(String prefix, String localName, String ns)
                {
                Prefix = prefix;
                LocalName = localName;
                NamespaceURI = ns;
                writer.WriteStartElement(prefix,localName,ns);
                }
            #endregion
            #region M:WriteEndElement
            /// <summary>When overridden in a derived class, closes one element and pops the corresponding namespace scope.</summary>
            /// <exception cref="T:System.InvalidOperationException">This results in an invalid XML document.</exception>
            /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
            public override void WriteEndElement()
                {
                writer.WriteEndElement();
                }
            #endregion
            #region M:WriteFullEndElement
            /// <summary>When overridden in a derived class, closes one element and pops the corresponding namespace scope.</summary>
            /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
            public override void WriteFullEndElement()
                {
                writer.WriteFullEndElement();
                }
            #endregion
            #region M:WriteStartAttribute(String,String,String)
            /// <summary>When overridden in a derived class, writes the start of an attribute with the specified prefix, local name, and namespace URI.</summary>
            /// <param name="prefix">The namespace prefix of the attribute.</param>
            /// <param name="localName">The local name of the attribute.</param>
            /// <param name="ns">The namespace URI for the attribute.</param>
            /// <exception cref="T:System.Text.EncoderFallbackException">There is a character in the buffer that is a valid XML character but is not valid for the output encoding. For example, if the output encoding is ASCII, you should only use characters from the range of 0 to 127 for element and attribute names. The invalid character might be in the argument of this method or in an argument of previous methods that were writing to the buffer. Such characters are escaped by character entity references when possible (for example, in text nodes or attribute values). However, the character entity reference is not allowed in element and attribute names, comments, processing instructions, or CDATA sections.</exception>
            /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
            public override void WriteStartAttribute(String prefix, String localName, String ns)
                {
                writer.WriteStartAttribute(prefix,localName,ns);
                }
            #endregion
            #region M:WriteEndAttribute
            /// <summary>When overridden in a derived class, closes the previous <see cref="M:System.Xml.XmlWriter.WriteStartAttribute(System.String,System.String)"/> call.</summary>
            /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
            public override void WriteEndAttribute()
                {
                writer.WriteEndAttribute();
                }
            #endregion
            #region M:WriteCData(String)
            /// <summary>When overridden in a derived class, writes out a &lt;![CDATA[...]]&gt; block containing the specified text.</summary>
            /// <param name="text">The text to place inside the CDATA block.</param>
            /// <exception cref="T:System.ArgumentException">The text would result in a non-well formed XML document.</exception>
            /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
            public override void WriteCData(String text) {
                if (!String.IsNullOrWhiteSpace(text)) {
                    writer.WriteRaw(String.Empty);
                    WriteIndent(writer).WriteRaw("<![CDATA[");
                    var values = text.Split(new []{ '\n' });
                    foreach (var value in values) {
                        WriteIndent(writer).WriteRaw($"{writer.Settings.IndentChars}{value.TrimEnd('\r')}");
                        }
                    WriteIndent(writer).WriteRaw($"{writer.Settings.IndentChars}]]>");
                    WriteIndent(writer);
                    }
                }
            #endregion
            #region M:WriteComment(String)
            /// <summary>When overridden in a derived class, writes out a comment &lt;!--...--&gt; containing the specified text.</summary>
            /// <param name="text">Text to place inside the comment.</param>
            /// <exception cref="T:System.ArgumentException">The text would result in a non-well-formed XML document.</exception>
            /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
            public override void WriteComment(String text)
                {
                writer.WriteComment(text);
                }
            #endregion
            #region M:WriteProcessingInstruction(String,String)
            /// <summary>When overridden in a derived class, writes out a processing instruction with a space between the name and text as follows: &lt;?name text?&gt;.</summary>
            /// <param name="name">The name of the processing instruction.</param>
            /// <param name="text">The text to include in the processing instruction.</param>
            /// <exception cref="T:System.ArgumentException">The text would result in a non-well formed XML document.
            /// <paramref name="name"/> is either <see langword="null"/> or <see langword="String.Empty"/>.This method is being used to create an XML declaration after <see cref="M:System.Xml.XmlWriter.WriteStartDocument"/> has already been called.</exception>
            /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
            public override void WriteProcessingInstruction(String name, String text)
                {
                writer.WriteProcessingInstruction(name,text);
                }
            #endregion
            #region M:WriteEntityRef(String)
            /// <summary>When overridden in a derived class, writes out an entity reference as <see langword="&amp;name;"/>.</summary>
            /// <param name="name">The name of the entity reference.</param>
            /// <exception cref="T:System.ArgumentException">
            /// <paramref name="name"/> is either <see langword="null"/> or <see langword="String.Empty"/>.</exception>
            /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
            public override void WriteEntityRef(String name)
                {
                writer.WriteEntityRef(name);
                }
            #endregion
            #region M:WriteCharEntity(Char)
            /// <summary>When overridden in a derived class, forces the generation of a character entity for the specified Unicode character value.</summary>
            /// <param name="ch">The Unicode character for which to generate a character entity.</param>
            /// <exception cref="T:System.ArgumentException">The character is in the surrogate pair character range, <see langword="0xd800"/> - <see langword="0xdfff"/>.</exception>
            /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
            public override void WriteCharEntity(Char ch)
                {
                writer.WriteCharEntity(ch);
                }
            #endregion
            #region M:WriteWhitespace(String)
            /// <summary>When overridden in a derived class, writes out the given white space.</summary>
            /// <param name="ws">The string of white space characters.</param>
            /// <exception cref="T:System.ArgumentException">The string contains non-white space characters.</exception>
            /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
            public override void WriteWhitespace(String ws)
                {
                writer.WriteWhitespace(ws);
                }
            #endregion
            #region M:WriteString(String)
            /// <summary>When overridden in a derived class, writes the given text content.</summary>
            /// <param name="text">The text to write.</param>
            /// <exception cref="T:System.ArgumentException">The text string contains an invalid surrogate pair.</exception>
            /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
            public override void WriteString(String text)
                {
                writer.WriteString(text);
                }
            #endregion
            #region M:WriteSurrogateCharEntity(Char,Char)
            /// <summary>When overridden in a derived class, generates and writes the surrogate character entity for the surrogate character pair.</summary>
            /// <param name="lowChar">The low surrogate. This must be a value between 0xDC00 and 0xDFFF.</param>
            /// <param name="highChar">The high surrogate. This must be a value between 0xD800 and 0xDBFF.</param>
            /// <exception cref="T:System.ArgumentException">An invalid surrogate character pair was passed.</exception>
            /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
            public override void WriteSurrogateCharEntity(Char lowChar, Char highChar)
                {
                writer.WriteSurrogateCharEntity(lowChar,highChar);
                }
            #endregion
            #region M:WriteChars(Char[],Int32,Int32)
            /// <summary>When overridden in a derived class, writes text one buffer at a time.</summary>
            /// <param name="buffer">Character array containing the text to write.</param>
            /// <param name="index">The position in the buffer indicating the start of the text to write.</param>
            /// <param name="count">The number of characters to write.</param>
            /// <exception cref="T:System.ArgumentNullException">
            /// <paramref name="buffer"/> is <see langword="null"/>.</exception>
            /// <exception cref="T:System.ArgumentOutOfRangeException">
            /// <paramref name="index"/> or <paramref name="count"/> is less than zero.-or-The buffer length minus <paramref name="index"/> is less than <paramref name="count"/>; the call results in surrogate pair characters being split or an invalid surrogate pair being written.</exception>
            /// <exception cref="T:System.ArgumentException">The <paramref name="buffer"/> parameter value is not valid.</exception>
            /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
            public override void WriteChars(Char[] buffer, Int32 index, Int32 count)
                {
                writer.WriteChars(buffer,index,count);
                }
            #endregion
            #region M:WriteRaw(Char[],Int32,Int32)
            /// <summary>When overridden in a derived class, writes raw markup manually from a character buffer.</summary>
            /// <param name="buffer">Character array containing the text to write.</param>
            /// <param name="index">The position within the buffer indicating the start of the text to write.</param>
            /// <param name="count">The number of characters to write.</param>
            /// <exception cref="T:System.ArgumentNullException">
            /// <paramref name="buffer"/> is <see langword="null"/>.</exception>
            /// <exception cref="T:System.ArgumentOutOfRangeException">
            /// <paramref name="index"/> or <paramref name="count"/> is less than zero. -or-The buffer length minus <paramref name="index"/> is less than <paramref name="count"/>.</exception>
            /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
            public override void WriteRaw(Char[] buffer, Int32 index, Int32 count)
                {
                writer.WriteRaw(buffer,index,count);
                }
            #endregion
            #region M:WriteRaw(String)
            /// <summary>When overridden in a derived class, writes raw markup manually from a string.</summary>
            /// <param name="data">String containing the text to write.</param>
            /// <exception cref="T:System.ArgumentException">
            /// <paramref name="data"/> is either <see langword="null"/> or <see langword="String.Empty"/>.</exception>
            /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
            public override void WriteRaw(String data)
                {
                writer.WriteRaw(data);
                }
            #endregion
            #region M:WriteBase64(Byte[],Int32,Int32)
            /// <summary>When overridden in a derived class, encodes the specified binary bytes as Base64 and writes out the resulting text.</summary>
            /// <param name="buffer">Byte array to encode.</param>
            /// <param name="index">The position in the buffer indicating the start of the bytes to write.</param>
            /// <param name="count">The number of bytes to write.</param>
            /// <exception cref="T:System.ArgumentNullException">
            /// <paramref name="buffer"/> is <see langword="null"/>.</exception>
            /// <exception cref="T:System.ArgumentOutOfRangeException">
            /// <paramref name="index"/> or <paramref name="count"/> is less than zero. -or-The buffer length minus <paramref name="index"/> is less than <paramref name="count"/>.</exception>
            /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
            public override void WriteBase64(Byte[] buffer, Int32 index, Int32 count)
                {
                writer.WriteBase64(buffer,index,count);
                }
            #endregion
            #region M:Close
            /// <summary>When overridden in a derived class, closes this stream and the underlying stream.</summary>
            /// <exception cref="T:System.InvalidOperationException">A call is made to write more output after <see langword="Close"/> has been called or the result of this call is an invalid XML document.</exception>
            /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
            public override void Close()
                {
                writer.Close();
                }
            #endregion
            #region M:Flush
            /// <summary>When overridden in a derived class, flushes whatever is in the buffer to the underlying streams and also flushes the underlying stream.</summary>
            /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
            public override void Flush()
                {
                writer.Flush();
                }
            #endregion
            #region M:LookupPrefix(String):String
            /// <summary>When overridden in a derived class, returns the closest prefix defined in the current namespace scope for the namespace URI.</summary>
            /// <param name="ns">The namespace URI whose prefix you want to find.</param>
            /// <returns>The matching prefix or <see langword="null"/> if no matching namespace URI is found in the current scope.</returns>
            /// <exception cref="T:System.ArgumentException">
            /// <paramref name="ns"/> is either <see langword="null"/> or <see langword="String.Empty"/>.</exception>
            /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
            public override String LookupPrefix(String ns)
                {
                return writer.LookupPrefix(ns);
                }
            #endregion

            public override WriteState WriteState { get{ return writer.WriteState; }}
            }

        #region M:Dispose(Boolean)
        /// <summary>Releases the unmanaged resources used by the <see cref="DefaultJsonWriter"/> and optionally releases the managed resources.</summary>
        /// <param name="disposing">true to release both managed and unmanaged resources; false to release only unmanaged resources.</param>
        protected override void Dispose(Boolean disposing) {
            if (!Disposed) {
                try
                    {
                    if (disposing) {
                        if (writer != null) {
                            if (!LeaveOpen)
                                {
                                ((IDisposable)writer).Dispose();
                                }
                            writer = null;
                            }
                        }
                    }
                finally
                    {
                    Disposed = true;
                    }
                }
            }
        #endregion
        #region M:WriteStartDocument
        /// <summary>When overridden in a derived class, writes the XML declaration with the version "1.0".</summary>
        /// <exception cref="T:System.InvalidOperationException">This is not the first write method called after the constructor.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteStartDocument()
            {
            writer.WriteStartDocument();
            }
        #endregion
        #region M:WriteStartDocument(Boolean)
        /// <summary>When overridden in a derived class, writes the XML declaration with the version "1.0" and the standalone attribute.</summary>
        /// <param name="standalone">If <see langword="true"/>, it writes "standalone=yes"; if <see langword="false"/>, it writes "standalone=no".</param>
        /// <exception cref="T:System.InvalidOperationException">This is not the first write method called after the constructor.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteStartDocument(Boolean standalone)
            {
            writer.WriteStartDocument(standalone);
            }
        #endregion
        #region M:WriteEndDocument
        /// <summary>When overridden in a derived class, closes any open elements or attributes and puts the writer back in the Start state.</summary>
        /// <exception cref="T:System.ArgumentException">The XML document is invalid.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteEndDocument()
            {
            writer.WriteEndDocument();
            }
        #endregion
        #region M:WriteDocType(String,String,String,String)
        /// <summary>When overridden in a derived class, writes the DOCTYPE declaration with the specified name and optional attributes.</summary>
        /// <param name="name">The name of the DOCTYPE. This must be non-empty.</param>
        /// <param name="pubid">If non-null it also writes PUBLIC "pubid" "sysid" where <paramref name="pubid"/> and <paramref name="sysid" /> are replaced with the value of the given arguments.</param>
        /// <param name="sysid">If <paramref name="pubid"/> is <see langword="null"/> and <paramref name="sysid"/> is non-null it writes SYSTEM "sysid" where <paramref name="sysid" /> is replaced with the value of this argument.</param>
        /// <param name="subset">If non-null it writes [subset] where subset is replaced with the value of this argument.</param>
        /// <exception cref="T:System.InvalidOperationException">This method was called outside the prolog (after the root element). </exception>
        /// <exception cref="T:System.ArgumentException">The value for <paramref name="name"/> would result in invalid XML.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteDocType(String name,String pubid,String sysid,String subset)
            {
            writer.WriteDocType(name,pubid,sysid,subset);
            }
        #endregion
        #region M:WriteStartElement(String,String,String)
        /// <summary>When overridden in a derived class, writes the specified start tag and associates it with the given namespace and prefix.</summary>
        /// <param name="prefix">The namespace prefix of the element.</param>
        /// <param name="localName">The local name of the element.</param>
        /// <param name="ns">The namespace URI to associate with the element.</param>
        /// <exception cref="T:System.InvalidOperationException">The writer is closed.</exception>
        /// <exception cref="T:System.Text.EncoderFallbackException">There is a character in the buffer that is a valid XML character but is not valid for the output encoding. For example, if the output encoding is ASCII, you should only use characters from the range of 0 to 127 for element and attribute names. The invalid character might be in the argument of this method or in an argument of previous methods that were writing to the buffer. Such characters are escaped by character entity references when possible (for example, in text nodes or attribute values). However, the character entity reference is not allowed in element and attribute names, comments, processing instructions, or CDATA sections.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteStartElement(String prefix,String localName,String ns)
            {
            writer.WriteStartElement(prefix,localName,ns);
            }
        #endregion
        #region M:WriteEndElement
        /// <summary>When overridden in a derived class, closes one element and pops the corresponding namespace scope.</summary>
        /// <exception cref="T:System.InvalidOperationException">This results in an invalid XML document.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteEndElement()
            {
            writer.WriteEndElement();
            }
        #endregion
        #region M:WriteFullEndElement
        /// <summary>When overridden in a derived class, closes one element and pops the corresponding namespace scope.</summary>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteFullEndElement()
            {
            writer.WriteFullEndElement();
            }
        #endregion
        #region M:WriteStartAttribute(String,String,String)
        /// <summary>When overridden in a derived class, writes the start of an attribute with the specified prefix, local name, and namespace URI.</summary>
        /// <param name="prefix">The namespace prefix of the attribute.</param>
        /// <param name="localName">The local name of the attribute.</param>
        /// <param name="ns">The namespace URI for the attribute.</param>
        /// <exception cref="T:System.Text.EncoderFallbackException">There is a character in the buffer that is a valid XML character but is not valid for the output encoding. For example, if the output encoding is ASCII, you should only use characters from the range of 0 to 127 for element and attribute names. The invalid character might be in the argument of this method or in an argument of previous methods that were writing to the buffer. Such characters are escaped by character entity references when possible (for example, in text nodes or attribute values). However, the character entity reference is not allowed in element and attribute names, comments, processing instructions, or CDATA sections. </exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteStartAttribute(String prefix,String localName,String ns)
            {
            writer.WriteStartAttribute(prefix,localName,ns);
            }
        #endregion
        #region M:WriteEndAttribute
        /// <summary>When overridden in a derived class, closes the previous <see cref="M:System.Xml.XmlWriter.WriteStartAttribute(System.String,System.String)"/> call.</summary>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteEndAttribute()
            {
            writer.WriteEndAttribute();
            }
        #endregion
        #region M:WriteCData(String)
        /// <summary>When overridden in a derived class, writes out a &lt;![CDATA[...]]&gt; block containing the specified text.</summary>
        /// <param name="text">The text to place inside the CDATA block.</param>
        /// <exception cref="T:System.ArgumentException">The text would result in a non-well formed XML document.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter" /> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException" /> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteCData(String text)
            {
            writer.WriteCData(text);
            }
        #endregion
        #region M:WriteComment(String)
        /// <summary>When overridden in a derived class, writes out a comment &lt;!--...--&gt; containing the specified text.</summary>
        /// <param name="text">Text to place inside the comment.</param>
        /// <exception cref="T:System.ArgumentException">The text would result in a non-well-formed XML document.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException" /> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteComment(String text)
            {
            writer.WriteComment(text);
            }
        #endregion
        #region M:WriteProcessingInstruction(String,String)
        /// <summary>When overridden in a derived class, writes out a processing instruction with a space between the name and text as follows: &lt;?name text?&gt;.</summary>
        /// <param name="name">The name of the processing instruction.</param>
        /// <param name="text">The text to include in the processing instruction.</param>
        /// <exception cref="T:System.ArgumentException">The text would result in a non-well formed XML document.<paramref name="name"/> is either <see langword="null"/> or <see langword="String.Empty"/>.This method is being used to create an XML declaration after <see cref="M:System.Xml.XmlWriter.WriteStartDocument"/> has already been called.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteProcessingInstruction(String name,String text)
            {
            writer.WriteProcessingInstruction(name,text);
            }
        #endregion
        #region M:WriteEntityRef(String)
        /// <summary>When overridden in a derived class, writes out an entity reference as <see langword="&amp;name;" />.</summary>
        /// <param name="name">The name of the entity reference.</param>
        /// <exception cref="T:System.ArgumentException"><paramref name="name"/> is either <see langword="null"/> or <see langword="String.Empty"/>.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteEntityRef(String name)
            {
            writer.WriteEntityRef(name);
            }
        #endregion
        #region M:WriteCharEntity(Char)
        /// <summary>When overridden in a derived class, forces the generation of a character entity for the specified Unicode character value.</summary>
        /// <param name="ch">The Unicode character for which to generate a character entity.</param>
        /// <exception cref="T:System.ArgumentException">The character is in the surrogate pair character range, <see langword="0xd800"/> - <see langword="0xdfff"/>.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteCharEntity(Char ch)
            {
            writer.WriteCharEntity(ch);
            }
        #endregion
        #region M:WriteWhitespace(String)
        /// <summary>When overridden in a derived class, writes out the given white space.</summary>
        /// <param name="ws">The string of white space characters.</param>
        /// <exception cref="T:System.ArgumentException">The string contains non-white space characters.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteWhitespace(String ws)
            {
            writer.WriteWhitespace(ws);
            }
        #endregion
        #region M:WriteString(String)
        /// <summary>When overridden in a derived class, writes the given text content.</summary>
        /// <param name="text">The text to write.</param>
        /// <exception cref="T:System.ArgumentException">The text string contains an invalid surrogate pair.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteString(String text)
            {
            writer.WriteString(text);
            }
        #endregion
        #region M:WriteSurrogateCharEntity(Char,Char)
        /// <summary>When overridden in a derived class, generates and writes the surrogate character entity for the surrogate character pair.</summary>
        /// <param name="lowChar">The low surrogate. This must be a value between 0xDC00 and 0xDFFF.</param>
        /// <param name="highChar">The high surrogate. This must be a value between 0xD800 and 0xDBFF.</param>
        /// <exception cref="T:System.ArgumentException">An invalid surrogate character pair was passed.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteSurrogateCharEntity(Char lowChar,Char highChar)
            {
            writer.WriteSurrogateCharEntity(lowChar,highChar);
            }
        #endregion
        #region M:WriteChars(Char[],Int32,Int32)
        /// <summary>When overridden in a derived class, writes text one buffer at a time.</summary>
        /// <param name="buffer">Character array containing the text to write.</param>
        /// <param name="index">The position in the buffer indicating the start of the text to write.</param>
        /// <param name="count">The number of characters to write.</param>
        /// <exception cref="T:System.ArgumentNullException"><paramref name="buffer"/> is <see langword="null"/>.</exception>
        /// <exception cref="T:System.ArgumentOutOfRangeException"><paramref name="index"/> or <paramref name="count"/> is less than zero.-or-The buffer length minus <paramref name="index"/> is less than <paramref name="count"/>; the call results in surrogate pair characters being split or an invalid surrogate pair being written.</exception>
        /// <exception cref="T:System.ArgumentException">The <paramref name="buffer" /> parameter value is not valid.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteChars(Char[] buffer,Int32 index,Int32 count)
            {
            writer.WriteChars(buffer,index,count);
            }
        #endregion
        #region M:WriteRaw(Char[],Int32,Int32)
        /// <summary>When overridden in a derived class, writes raw markup manually from a character buffer.</summary>
        /// <param name="buffer">Character array containing the text to write.</param>
        /// <param name="index">The position within the buffer indicating the start of the text to write.</param>
        /// <param name="count">The number of characters to write.</param>
        /// <exception cref="T:System.ArgumentNullException"><paramref name="buffer"/> is <see langword="null"/>.</exception>
        /// <exception cref="T:System.ArgumentOutOfRangeException"><paramref name="index"/> or <paramref name="count"/> is less than zero. -or-The buffer length minus <paramref name="index"/> is less than <paramref name="count"/>.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteRaw(Char[] buffer,Int32 index,Int32 count)
            {
            writer.WriteRaw(buffer,index,count);
            }
        #endregion
        #region M:WriteRaw(String)
        /// <summary>When overridden in a derived class, writes raw markup manually from a string.</summary>
        /// <param name="data">String containing the text to write.</param>
        /// <exception cref="T:System.ArgumentException"><paramref name="data"/> is either <see langword="null"/> or <see langword="String.Empty"/>.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteRaw(String data)
            {
            writer.WriteRaw(data);
            }
        #endregion
        #region M:WriteBase64(Byte[],Int32,Int32)
        /// <summary>When overridden in a derived class, encodes the specified binary bytes as Base64 and writes out the resulting text.</summary>
        /// <param name="buffer">Byte array to encode.</param>
        /// <param name="index">The position in the buffer indicating the start of the bytes to write.</param>
        /// <param name="count">The number of bytes to write.</param>
        /// <exception cref="T:System.ArgumentNullException"><paramref name="buffer"/> is <see langword="null"/>. </exception>
        /// <exception cref="T:System.ArgumentOutOfRangeException"><paramref name="index"/> or <paramref name="count"/> is less than zero. -or-The buffer length minus <paramref name="index"/> is less than <paramref name="count"/>.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteBase64(Byte[] buffer,Int32 index,Int32 count)
            {
            writer.WriteBase64(buffer,index,count);
            }
        #endregion
        #region M:Flush
        /// <summary>When overridden in a derived class, flushes whatever is in the buffer to the underlying streams and also flushes the underlying stream.</summary>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void Flush()
            {
            writer.Flush();
            }
        #endregion
        #region M:LookupPrefix(String):String
        /// <summary>When overridden in a derived class, returns the closest prefix defined in the current namespace scope for the namespace URI.</summary>
        /// <param name="ns">The namespace URI whose prefix you want to find.</param>
        /// <returns>The matching prefix or <see langword="null"/> if no matching namespace URI is found in the current scope.</returns>
        /// <exception cref="T:System.ArgumentException"><paramref name="ns"/> is either <see langword="null"/> or <see langword="String.Empty"/>.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override String LookupPrefix(String ns)
            {
            return writer.LookupPrefix(ns);
            }
        #endregion
        #region M:ISqlXmlWriter.WriteAttribute(Boolean,String,Object)
        void ISqlXmlWriter.WriteAttribute(Boolean newline,String localName,Object value) {
            writer.WriteAttribute(newline,localName,value);
            }
        #endregion

        private InternalXmlWriter writer;
        private Boolean Disposed;
        private Boolean LeaveOpen;
        }
    }
