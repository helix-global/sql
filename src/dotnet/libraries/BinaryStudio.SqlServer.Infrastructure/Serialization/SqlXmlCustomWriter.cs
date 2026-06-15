using System;
using System.ComponentModel;
using System.Xml;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public abstract class SqlXmlCustomWriter : XmlWriter,ISqlXmlWriter,IServiceProvider
        {
        #region P:DontThrowOnInvalidSurrogatePairs:Boolean
        public static Boolean DontThrowOnInvalidSurrogatePairs { get {
            var type = typeof(XmlWriter).Assembly.GetType("System.LocalAppContextSwitches");
            return (Boolean)type.GetProperty("DontThrowOnInvalidSurrogatePairs").GetValue(null);
            }}
        #endregion

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
        #region M:ISqlXmlWriter.WriteAttribute<T>(String,String,String,T)
        /// <summary>When overridden in a derived class, writes out the attribute with the specified prefix, local name, namespace URI, and value.</summary>
        /// <param name="prefix">The namespace prefix of the attribute.</param>
        /// <param name="localName">The local name of the attribute.</param>
        /// <param name="ns">The namespace URI of the attribute.</param>
        /// <param name="value">The value of the attribute.</param>
        /// <exception cref="T:System.InvalidOperationException">The state of writer is not <see langword="WriteState.Element"/> or writer is closed.</exception>
        /// <exception cref="T:System.ArgumentException">The <see langword="xml:space"/> or <see langword="xml:lang"/> attribute value is invalid.</exception>
        /// <exception cref="T:System.Xml.XmlException">The <paramref name="localName"/> or <paramref name="ns"/> is <see langword="null"/>.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:BinaryStudio.SqlServer.Infrastructure.ISqlXmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        void ISqlXmlWriter.WriteAttribute<T>(String prefix,String localName,String ns,T value) {
            if ((value == null) || (value is DBNull)) { return; }
            if (String.IsNullOrWhiteSpace(value.ToString())) { return; }
            WriteAttributeString(prefix,localName,ns,ConvertToString(value));
            }
        #endregion
        #region M:ISqlXmlWriter.WriteAttribute<T>(String,String,T)
        /// <summary>When overridden in a derived class, writes an attribute with the specified local name, namespace URI, and value.</summary>
        /// <param name="localName">The local name of the attribute.</param>
        /// <param name="ns">The namespace URI to associate with the attribute.</param>
        /// <param name="value">The value of the attribute.</param>
        /// <exception cref="T:System.InvalidOperationException">The state of writer is not <see langword="WriteState.Element"/> or writer is closed.</exception>
        /// <exception cref="T:System.ArgumentException">The <see langword="xml:space"/> or <see langword="xml:lang"/> attribute value is invalid.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:BinaryStudio.SqlServer.Infrastructure.ISqlXmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        void ISqlXmlWriter.WriteAttribute<T>(String localName,String ns,T value) {
            if ((value == null) || (value is DBNull)) { return; }
            if (String.IsNullOrWhiteSpace(value.ToString())) { return; }
            WriteAttributeString(localName,ns,ConvertToString(value));
            }
        #endregion
        #region M:ISqlXmlWriter.WriteAttribute<T>(String,T)
        /// <summary>When overridden in a derived class, writes out the attribute with the specified local name and value.</summary>
        /// <param name="localName">The local name of the attribute.</param>
        /// <param name="value">The value of the attribute.</param>
        /// <exception cref="T:System.InvalidOperationException">The state of writer is not <see langword="WriteState.Element"/> or writer is closed.</exception>
        /// <exception cref="T:System.ArgumentException">The <see langword="xml:space"/> or <see langword="xml:lang"/> attribute value is invalid.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:BinaryStudio.SqlServer.Infrastructure.ISqlXmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        void ISqlXmlWriter.WriteAttribute<T>(String localName,T value) {
            if ((value == null) || (value is DBNull)) { return; }
            if (String.IsNullOrWhiteSpace(value.ToString())) { return; }
            WriteAttributeString(localName,ConvertToString(value));
            }
        #endregion
        #region M:ISqlXmlWriter.WriteAttribute<T>(String,T,TypeConverter)
        /// <summary>Writes out the attribute with the specified local name and value using specified converter.</summary>
        /// <param name="localName">The local name of the attribute.</param>
        /// <param name="value">The value of the attribute.</param>
        /// <param name="converter">The value converter.</param>
        /// <exception cref="T:System.InvalidOperationException">The state of writer is not <see langword="WriteState.Element"/> or writer is closed.</exception>
        /// <exception cref="T:System.ArgumentException">The <see langword="xml:space"/> or <see langword="xml:lang"/> attribute value is invalid.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:BinaryStudio.SqlServer.Infrastructure.ISqlXmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        void ISqlXmlWriter.WriteAttribute<T>(String localName,T value,TypeConverter converter) {
            if ((value == null) || (value is DBNull)) { return; }
            if (String.IsNullOrWhiteSpace(value.ToString())) { return; }
            WriteAttributeString(localName,ConvertToString(value,converter));
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
        #region M:ISqlXmlWriter.WriteCData(String)
        /// <summary>Writes out a <![CDATA[...]]> block containing the specified text.</summary>
        /// <param name="text">The text to place inside the CDATA block.</param>
        /// <exception cref="T:System.ArgumentException">The <paramref name="localName"/> value is <see langword="null"/> or an empty string.-or-The parameter values are not valid.</exception>
        /// <exception cref="T:System.Text.EncoderFallbackException">There is a character in the buffer that is a valid XML character but is not valid for the output encoding. For example, if the output encoding is ASCII, you should only use characters from the range of 0 to 127 for element and attribute names. The invalid character might be in the argument of this method or in an argument of previous methods that were writing to the buffer. Such characters are escaped by character entity references when possible (for example, in text nodes or attribute values). However, the character entity reference is not allowed in element and attribute names, comments, processing instructions, or CDATA sections.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:BinaryStudio.SqlServer.Infrastructure.ISqlXmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        void ISqlXmlWriter.WriteCData(String text) {
            if (String.IsNullOrWhiteSpace(text)) { return; }
            WriteCData(text);
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
        #region M:ISqlXmlWriter.ScheduleNewLineForNextAttribute:ISqlXmlWriter
        ISqlXmlWriter ISqlXmlWriter.ScheduleNewLineForNextAttribute()
            {
            ScheduleNewLineForNextAttribute();
            return this;
            }
        protected internal virtual void ScheduleNewLineForNextAttribute(){
            }
        #endregion
        #region M:ISqlXmlWriter.StopScheduleNewLineForNextAttribute:ISqlXmlWriter
        ISqlXmlWriter ISqlXmlWriter.StopScheduleNewLineForNextAttribute()
            {
            StopScheduleNewLineForNextAttribute();
            return this;
            }
        protected internal virtual void StopScheduleNewLineForNextAttribute(){
            }
        #endregion
        #region M:ConvertToString(Object):String
        /// <summary>Converts the specified value to a string representation.</summary>
        /// <param name="value">The <see cref="T:System.Object" /> to convert.</param>
        /// <returns>An <see cref="T:System.Object" /> that represents the converted value.</returns>
        /// <exception cref="T:System.NotSupportedException">The conversion cannot be performed.</exception>
        protected virtual String ConvertToString(Object value) {
            return ConvertToString(value,null);
            }
        #endregion
        #region M:ConvertToString(Object,TypeConverter):String
        /// <summary>Converts the specified value to a string representation.</summary>
        /// <param name="value">The <see cref="T:System.Object" /> to convert.</param>
        /// <param name="converter">The value converter.</param>
        /// <returns>An <see cref="T:System.Object" /> that represents the converted value.</returns>
        /// <exception cref="T:System.NotSupportedException">The conversion cannot be performed.</exception>
        protected virtual String ConvertToString(Object value,TypeConverter converter) {
            if ((value == null) || (value is DBNull)) { return null; }
            if (converter == null) {
                if (value is DateTime DT) { return DT.ToString("s");   }
                if (value is Guid   GUID) { return GUID.ToString("B"); }
                return value.ToString();
                }
            return converter.ConvertToInvariantString(value);
            }
        #endregion
        #region M:IServiceProvider.GetService(Type):Object
        /// <summary>Gets the service object of the specified type.</summary>
        /// <param name="service">An object that specifies the type of service object to get.</param>
        /// <returns>A service object of type <paramref name="service"/>.
        /// -or-
        /// <see langword="null"/> if there is no service object of type <paramref name="service"/>.</returns>
        Object IServiceProvider.GetService(Type service)
            {
            return GetService(service);
            }
        #endregion
        #region M:GetService(Type):Object
        /// <summary>Returns an object that represents a service provided by the <see cref="T:System.ComponentModel.Component"/> or by its <see cref="T:System.ComponentModel.Container"/>.</summary>
        /// <param name="service">A service provided by the <see cref="T:System.ComponentModel.Component"/>.</param>
        /// <returns>An <see cref="T:System.Object"/> that represents a service provided by the <see cref="T:System.ComponentModel.Component"/>, or <see langword="null"/> if the <see cref="T:System.ComponentModel.Component"/> does not provide the specified service.</returns>
        protected virtual Object GetService(Type service) {
            if (service == null) { return null; }
            if (service.IsAssignableFrom(GetType())) { return this; }
            return null;
            }
        #endregion
        #region M:GetService<T>({out}T):Boolean
        protected Boolean GetService<T>(out T service)
            where T : class
            {
            service = GetService(typeof(T)) as T;
            return service != null;
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

        protected const String Xml_XmlnsPrefix = "Prefix \"xmlns\" is reserved for use by XML.";
        protected const String Xml_NoRoot = "Document does not have a root element.";
        protected const String Xml_EmptyName = "The empty string '' is not a valid name.";
        protected const String Xml_DtdNotAllowedInFragment = "DTD is not allowed in XML fragments.";
        protected const String Xml_ConformanceLevelFragment = "Make sure that the ConformanceLevel setting is set to ConformanceLevel.Fragment or ConformanceLevel.Auto if you want to write an XML fragment.";
        protected const String Xml_WrongToken = "Token {0} in state {1} would result in an invalid XML document.";
        protected const String Xml_InvalidNameCharsDetail = "Invalid name character in '{0}'. The '{1}' character, hexadecimal value {2}, cannot be included in a name.";
        protected const String Xml_ClosedOrError = "The XmlReader is closed or in error state.";
        protected const String Xml_DupAttributeName = "'{0}' is a duplicate attribute name.";
        protected const String Xml_XmlPrefix = "Prefix \"xml\" is reserved for use by XML and can be mapped only to namespace name \"http://www.w3.org/XML/1998/namespace\".";
        protected const String Xml_NamespaceDeclXmlXmlns = "Prefix '{0}' cannot be mapped to namespace name reserved for \"xml\" or \"xmlns\".";
        protected const String Xml_DtdAlreadyWritten = "The DTD has already been written out.";
        protected const String Xml_InvalidCharacter = "'{0}', hexadecimal value {1}, is an invalid character.";
        protected const String Xml_EmptyLocalName = "The empty string '' is not a valid local name.";
        protected const String Xml_PrefixForEmptyNs = "Cannot use a prefix with an empty namespace.";
        protected const String Xml_NoStartTag = "There was no XML start tag open.";
        protected const String Xml_CanNotBindToReservedNamespace = "Cannot bind to the reserved namespace.";
        protected const String Xml_InvalidXmlSpace = "'{0}' is an invalid xml:space value.";
        protected const String Xml_DupXmlDecl = "Cannot write XML declaration. WriteStartDocument method has already written it.";
        protected const String Xml_CannotWriteXmlDecl = "Cannot write XML declaration. XML declaration can be only at the beginning of the document.";
        protected const String Xml_InvalidSurrogateMissingLowChar = "The surrogate pair is invalid. Missing a low surrogate character.";
        protected const String Xml_NonWhitespace = "Only white space characters should be used.";
        protected const String Xml_UndefNamespace = "The '{0}' namespace is not defined.";
        protected const String Xml_CannotStartDocumentOnFragment = "WriteStartDocument cannot be called on writers created with ConformanceLevel.Fragment.";
        protected const String Xml_RedefinePrefix = "The prefix '{0}' cannot be redefined from '{1}' to '{2}' within the same start element tag.";
        protected const String Xml_IndentCharsNotWhitespace="XmlWriterSettings.{0} can contain only valid XML white space characters when XmlWriterSettings.CheckCharacters and XmlWriterSettings.NewLineOnAttributes are true.";
        protected const String Xml_InvalidSurrogateHighChar= "Invalid high surrogate character (0x{0}). A high surrogate character must have a value from range (0xD800 - 0xDBFF).";
        protected const String Xml_InvalidCharsInIndent="XmlWriterSettings.{0} can contain only valid XML text content characters when XmlWriterSettings.CheckCharacters is true. {1}";
        protected const String Xml_InvalidOperation = "Operation is not valid due to the current state of the object.";
        }
    }
