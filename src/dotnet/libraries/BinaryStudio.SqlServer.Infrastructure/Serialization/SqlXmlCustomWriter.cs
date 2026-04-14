using DocumentFormat.OpenXml.Bibliography;
using System;
using System.Xml;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public abstract class SqlXmlCustomWriter : XmlWriter,ISqlXmlWriter
        {
        public const String URI_CTRL  = "urn:schemas.helix.global:control";
        protected internal virtual Boolean NewLineOnAttributes { get { return false; } set { }}

        #region M:ElementGroup(String,String,String):IDisposable
        /// <summary>Begins a new XML element group with the specified prefix, local name, and namespace, and returns an IDisposable that ends the group when disposed.</summary>
        /// <param name="prefix">The namespace prefix to associate with the element group. Can be null or empty to indicate no prefix.</param>
        /// <param name="localName">The local name of the XML element group. Cannot be null or empty.</param>
        /// <param name="ns">The namespace URI to associate with the element group. Can be null or empty to indicate no namespace.</param>
        /// <returns>An IDisposable that, when disposed, ends the current element group.</returns>
        /// <remarks>
        /// Use a using statement to ensure the element group is properly closed, even if an
        /// exception occurs.
        /// </remarks>
        public IDisposable ElementGroup(String prefix,String localName,String ns)
            {
            return new ElementGroupScope(this,prefix,localName,ns);
            }
        #endregion
        #region M:ElementGroup(String,String):IDisposable
        /// <summary>Begins a new XML element group with the specified local name and namespace, and returns an IDisposable that ends the group when disposed.</summary>
        /// <param name="localName">The local name of the XML element group to start. Cannot be null.</param>
        /// <param name="ns">The namespace URI of the XML element group. Can be an empty string for no namespace.</param>
        /// <returns>An IDisposable that, when disposed, ends the XML element group started by this method.</returns>
        /// <remarks>
        /// Use this method to ensure that the XML element group is properly closed, even if an
        /// exception occurs. Typically used with a using statement to manage the element group's lifetime.
        /// </remarks>
        public IDisposable ElementGroup(String localName,String ns)
            {
            return new ElementGroupScope(this,localName,ns);
            }
        #endregion
        #region M:ElementGroup(String):IDisposable
        /// <summary>Begins a new XML element with the specified local name and returns an IDisposable that closes the element when disposed.</summary>
        /// <param name="localName">The local name of the XML element to start. Cannot be null.</param>
        /// <returns>An IDisposable that, when disposed, closes the started XML element.</returns>
        /// <remarks>
        /// Use this method within a using statement to ensure the XML element is properly
        /// closed, even if an exception occurs.
        /// </remarks>
        public IDisposable ElementGroup(String localName)
            {
            return new ElementGroupScope(this,localName);
            }
        #endregion
        #region M:NewLineOnAttribute:IDisposable
        /// <summary>Returns an IDisposable that, when disposed, will reset the writer's state to write a new line before the next attribute.</summary>
        /// <returns>An IDisposable that, when disposed, will reset the writer's state to write a new line before the next attribute.</returns>
        /// <remarks>
        /// Use this method within a using statement to ensure that the writer's state is properly
        /// reset, even if an exception occurs.
        /// </remarks>
        public IDisposable NewLineOnAttribute()
            {
            return new NewLineOnAttributeScope(this);
            }
        #endregion
        #region M:ISqlXmlWriter.WriteAttribute(String,String,String,Object)
        /// <summary>When overridden in a derived class, writes out the attribute with the specified prefix, local name, namespace URI, and value.</summary>
        /// <param name="prefix">The namespace prefix of the attribute.</param>
        /// <param name="localName">The local name of the attribute.</param>
        /// <param name="ns">The namespace URI of the attribute.</param>
        /// <param name="value">The value of the attribute.</param>
        /// <exception cref="T:System.InvalidOperationException">The state of writer is not <see langword="WriteState.Element"/> or writer is closed.</exception>
        /// <exception cref="T:System.ArgumentException">The <see langword="xml:space"/> or <see langword="xml:lang"/> attribute value is invalid.</exception>
        /// <exception cref="T:System.Xml.XmlException">The <paramref name="localName"/> or <paramref name="ns"/> is <see langword="null"/>.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:BinaryStudio.SqlServer.Infrastructure.ISqlXmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        void ISqlXmlWriter.WriteAttribute(String prefix,String localName,String ns,Object value) {
            if ((value == null) || (value is DBNull)) { return; }
            WriteAttributeString(prefix,localName,ns,ConvertToString(value));
            }
        #endregion
        #region M:ISqlXmlWriter.WriteAttribute(String,String,Object)
        /// <summary>When overridden in a derived class, writes an attribute with the specified local name, namespace URI, and value.</summary>
        /// <param name="localName">The local name of the attribute.</param>
        /// <param name="ns">The namespace URI to associate with the attribute.</param>
        /// <param name="value">The value of the attribute.</param>
        /// <exception cref="T:System.InvalidOperationException">The state of writer is not <see langword="WriteState.Element"/> or writer is closed.</exception>
        /// <exception cref="T:System.ArgumentException">The <see langword="xml:space"/> or <see langword="xml:lang"/> attribute value is invalid.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:BinaryStudio.SqlServer.Infrastructure.ISqlXmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        void ISqlXmlWriter.WriteAttribute(String localName,String ns,Object value) {
            if ((value == null) || (value is DBNull)) { return; }
            WriteAttributeString(localName,ns,ConvertToString(value));
            }
        #endregion
        #region M:ISqlXmlWriter.WriteAttribute(String,Object)
        /// <summary>When overridden in a derived class, writes out the attribute with the specified local name and value.</summary>
        /// <param name="localName">The local name of the attribute.</param>
        /// <param name="value">The value of the attribute.</param>
        /// <exception cref="T:System.InvalidOperationException">The state of writer is not <see langword="WriteState.Element"/> or writer is closed.</exception>
        /// <exception cref="T:System.ArgumentException">The <see langword="xml:space"/> or <see langword="xml:lang"/> attribute value is invalid.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:BinaryStudio.SqlServer.Infrastructure.ISqlXmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        void ISqlXmlWriter.WriteAttribute(String localName,Object value) {
            if ((value == null) || (value is DBNull)) { return; }
            WriteAttributeString(localName,ConvertToString(value));
            }
        #endregion
        #region M:ISqlXmlWriter.WriteCData(String,String,String,String)
        /// <summary>Writes an element with the specified prefix, local name, namespace URI, and CDATA block.</summary>
        /// <param name="prefix">The prefix of the element.</param>
        /// <param name="localName">The local name of the element.</param>
        /// <param name="ns">The namespace URI of the element.</param>
        /// <param name="text">The text to place inside the CDATA block.</param>
        /// <exception cref="T:System.ArgumentException">The <paramref name="localName"/> value is <see langword="null"/> or an empty string.-or-The parameter values are not valid.</exception>
        /// <exception cref="T:System.Text.EncoderFallbackException">There is a character in the buffer that is a valid XML character but is not valid for the output encoding. For example, if the output encoding is ASCII, you should only use characters from the range of 0 to 127 for element and attribute names. The invalid character might be in the argument of this method or in an argument of previous methods that were writing to the buffer. Such characters are escaped by character entity references when possible (for example, in text nodes or attribute values). However, the character entity reference is not allowed in element and attribute names, comments, processing instructions, or CDATA sections.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:BinaryStudio.SqlServer.Infrastructure.ISqlXmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        void ISqlXmlWriter.WriteCData(String prefix,String localName,String ns,String text) {
            if (String.IsNullOrWhiteSpace(text)) { return; }
            using (ElementGroup(prefix,localName,ns)) {
                WriteCData(text);
                }
            }
        #endregion
        #region M:ISqlXmlWriter.WriteCData(String,String,String)
        /// <summary>Writes an element with the specified local name, namespace URI, and CDATA block.</summary>
        /// <param name="localName">The local name of the element.</param>
        /// <param name="ns">The namespace URI to associate with the element.</param>
        /// <param name="text">The text to place inside the CDATA block.</param>
        /// <exception cref="T:System.ArgumentException">The <paramref name="localName"/> value is <see langword="null"/> or an empty string.-or-The parameter values are not valid.</exception>
        /// <exception cref="T:System.Text.EncoderFallbackException">There is a character in the buffer that is a valid XML character but is not valid for the output encoding. For example, if the output encoding is ASCII, you should only use characters from the range of 0 to 127 for element and attribute names. The invalid character might be in the argument of this method or in an argument of previous methods that were writing to the buffer. Such characters are escaped by character entity references when possible (for example, in text nodes or attribute values). However, the character entity reference is not allowed in element and attribute names, comments, processing instructions, or CDATA sections.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:BinaryStudio.SqlServer.Infrastructure.ISqlXmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        void ISqlXmlWriter.WriteCData(String localName,String ns,String text) {
            if (String.IsNullOrWhiteSpace(text)) { return; }
            using (ElementGroup(localName,ns)) {
                WriteCData(text);
                }
            }
        #endregion
        #region M:ISqlXmlWriter.WriteCData(String,String)
        /// <summary>Writes an element with the specified local name and CDATA block.</summary>
        /// <param name="localName">The local name of the element.</param>
        /// <param name="text">The text to place inside the CDATA block.</param>
        /// <exception cref="T:System.ArgumentException">The <paramref name="localName"/> value is <see langword="null"/> or an empty string.-or-The parameter values are not valid.</exception>
        /// <exception cref="T:System.Text.EncoderFallbackException">There is a character in the buffer that is a valid XML character but is not valid for the output encoding. For example, if the output encoding is ASCII, you should only use characters from the range of 0 to 127 for element and attribute names. The invalid character might be in the argument of this method or in an argument of previous methods that were writing to the buffer. Such characters are escaped by character entity references when possible (for example, in text nodes or attribute values). However, the character entity reference is not allowed in element and attribute names, comments, processing instructions, or CDATA sections.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:BinaryStudio.SqlServer.Infrastructure.ISqlXmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        void ISqlXmlWriter.WriteCData(String localName,String text) {
            if (String.IsNullOrWhiteSpace(text)) { return; }
            using (ElementGroup(localName)) {
                WriteCData(text);
                }
            }
        #endregion
        #region M:ISqlXmlWriter.WriteBase64(String,String,String,Byte[])
        /// <summary>Writes an element with the specified prefix, local name, namespace URI, and BASE64 block.</summary>
        /// <param name="prefix">The prefix of the element.</param>
        /// <param name="localName">The local name of the element.</param>
        /// <param name="ns">The namespace URI of the element.</param>
        /// <param name="buffer">Byte array to encode.</param>
        /// <exception cref="T:System.ArgumentException">The <paramref name="localName"/> value is <see langword="null"/> or an empty string.-or-The parameter values are not valid.</exception>
        /// <exception cref="T:System.Text.EncoderFallbackException">There is a character in the buffer that is a valid XML character but is not valid for the output encoding. For example, if the output encoding is ASCII, you should only use characters from the range of 0 to 127 for element and attribute names. The invalid character might be in the argument of this method or in an argument of previous methods that were writing to the buffer. Such characters are escaped by character entity references when possible (for example, in text nodes or attribute values). However, the character entity reference is not allowed in element and attribute names, comments, processing instructions, or CDATA sections.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:BinaryStudio.SqlServer.Infrastructure.ISqlXmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        void ISqlXmlWriter.WriteBase64(String prefix,String localName,String ns,Byte[] buffer) {
            if (buffer == null) { return; }
            using (ElementGroup(prefix,localName,ns)) {
                WriteAttributeString("x","base64",URI_CTRL,"true");
                WriteBase64(buffer,0,buffer.Length);
                }
            }
        #endregion
        #region M:ISqlXmlWriter.WriteBase64(String,String,Byte[])
        /// <summary>Writes an element with the specified local name, namespace URI, and BASE64 block.</summary>
        /// <param name="localName">The local name of the element.</param>
        /// <param name="ns">The namespace URI of the element.</param>
        /// <param name="buffer">Byte array to encode.</param>
        /// <exception cref="T:System.ArgumentException">The <paramref name="localName"/> value is <see langword="null"/> or an empty string.-or-The parameter values are not valid.</exception>
        /// <exception cref="T:System.Text.EncoderFallbackException">There is a character in the buffer that is a valid XML character but is not valid for the output encoding. For example, if the output encoding is ASCII, you should only use characters from the range of 0 to 127 for element and attribute names. The invalid character might be in the argument of this method or in an argument of previous methods that were writing to the buffer. Such characters are escaped by character entity references when possible (for example, in text nodes or attribute values). However, the character entity reference is not allowed in element and attribute names, comments, processing instructions, or CDATA sections.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:BinaryStudio.SqlServer.Infrastructure.ISqlXmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        void ISqlXmlWriter.WriteBase64(String localName,String ns,Byte[] buffer) {
            if (buffer == null) { return; }
            using (ElementGroup(localName,ns)) {
                WriteAttributeString("x","base64",URI_CTRL,"true");
                WriteBase64(buffer,0,buffer.Length);
                }
            }
        #endregion
        #region M:ISqlXmlWriter.WriteBase64(String,Byte[])
        /// <summary>Writes an element with the specified local name and BASE64 block.</summary>
        /// <param name="localName">The local name of the element.</param>
        /// <param name="buffer">Byte array to encode.</param>
        /// <exception cref="T:System.ArgumentException">The <paramref name="localName"/> value is <see langword="null"/> or an empty string.-or-The parameter values are not valid.</exception>
        /// <exception cref="T:System.Text.EncoderFallbackException">There is a character in the buffer that is a valid XML character but is not valid for the output encoding. For example, if the output encoding is ASCII, you should only use characters from the range of 0 to 127 for element and attribute names. The invalid character might be in the argument of this method or in an argument of previous methods that were writing to the buffer. Such characters are escaped by character entity references when possible (for example, in text nodes or attribute values). However, the character entity reference is not allowed in element and attribute names, comments, processing instructions, or CDATA sections.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:BinaryStudio.SqlServer.Infrastructure.ISqlXmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        void ISqlXmlWriter.WriteBase64(String localName,Byte[] buffer) {
            if (buffer == null) { return; }
            using (ElementGroup(localName)) {
                WriteAttributeString("x","base64",URI_CTRL,"true");
                WriteBase64(buffer,0,buffer.Length);
                }
            }
        #endregion
        #region M:ConvertToString(Object):String
        /// <summary>Converts the specified value to a string representation.</summary>
        /// <param name="value">The <see cref="T:System.Object" /> to convert.</param>
        /// <returns>An <see cref="T:System.Object" /> that represents the converted value.</returns>
        /// <exception cref="T:System.NotSupportedException">The conversion cannot be performed.</exception>
        protected virtual String ConvertToString(Object value) {
            if ((value == null) || (value is DBNull)) { return null; }
            if (value is DateTime DT) { return DT.ToString("s");   }
            if (value is Guid   GUID) { return GUID.ToString("B"); }
            return value.ToString();
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
            public ElementGroupScope(XmlWriter writer,String prefix,String localName,String ns)
                :this(writer)
                {
                writer.WriteStartElement(prefix,localName,ns);
                }
            #endregion
            #region ctor{XmlWriter,String,String}
            public ElementGroupScope(XmlWriter writer,String localName,String ns)
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

        private class NewLineOnAttributeScope: IDisposable
            {
            private SqlXmlCustomWriter writer;
            #region ctor{SqlXmlCustomWriter}
            public NewLineOnAttributeScope(SqlXmlCustomWriter writer)
                {
                this.writer = writer;
                writer.NewLineOnAttributes = true;
                }
            #endregion

             public void Dispose()
                {
                writer.NewLineOnAttributes = false;
                writer = null;
                }
            }
        }
    }
