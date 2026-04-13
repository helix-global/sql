using System;
using System.Xml;
using System.Xml.XPath;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    /// <summary>
    /// Implementations of XmlRawWriter are intended to be wrapped by the XmlWellFormedWriter.  The
    /// well-formed writer performs many checks in behalf of the raw writer, and keeps state that the
    /// raw writer otherwise would have to keep.  Therefore, the well-formed writer will call the
    /// XmlRawWriter using the following rules, in order to make raw writers easier to implement:
    ///
    ///  1. The well-formed writer keeps a stack of element names, and always calls
    ///     WriteEndElement(string, string, string) instead of WriteEndElement().
    ///  2. The well-formed writer tracks namespaces, and will pass himself in via the
    ///     WellformedWriter property. It is used in the XmlRawWriter's implementation of IXmlNamespaceResolver.
    ///     Thus, LookupPrefix does not have to be implemented.
    ///  3. The well-formed writer tracks write states, so the raw writer doesn't need to.
    ///  4. The well-formed writer will always call StartElementContent.
    ///  5. The well-formed writer will always call WriteNamespaceDeclaration for namespace nodes,
    ///     rather than calling WriteStartAttribute(). If the writer is supporting namespace declarations in chunks
    ///     (SupportsNamespaceDeclarationInChunks is true), the XmlWellFormedWriter will call WriteStartNamespaceDeclaration,
    ///      then any method that can be used to write out a value of an attribute (WriteString, WriteChars, WriteRaw, WriteCharEntity...) 
    ///      and then WriteEndNamespaceDeclaration - instead of just a single WriteNamespaceDeclaration call. This feature will be 
    ///      supported by raw writers serializing to text that wish to preserve the attribute value escaping etc.
    ///  6. The well-formed writer guarantees a well-formed document, including correct call sequences,
    ///     correct namespaces, and correct document rule enforcement.
    ///  7. All element and attribute names will be fully resolved and validated.  Null will never be
    ///     passed for any of the name parts.
    ///  8. The well-formed writer keeps track of xml:space and xml:lang.
    ///  9. The well-formed writer verifies NmToken, Name, and QName values and calls WriteString().
    /// </summary>
    internal abstract class XmlRawWriter : XmlWriter
        {
        //
        // Fields
        //
        // base64 converter
        protected XmlRawWriterBase64Encoder base64Encoder;

        // namespace resolver
        protected IXmlNamespaceResolver resolver;

        #region P:WriteState:WriteState
        // Raw writers do not have to keep track of write states.
        public override WriteState WriteState
            {
            get
                {
                throw new InvalidOperationException(Xml_InvalidOperation);
                }
            }
        #endregion
        #region P:XmlSpace:XmlSpace
        // Raw writers do not have to keep track of xml:space.
        public override XmlSpace XmlSpace
            {
            get { throw new InvalidOperationException(Xml_InvalidOperation); }
            }
        #endregion
        #region P:XmlLang:String
        // Raw writers do not have to keep track of xml:lang.
        public override String XmlLang
            {
            get { throw new InvalidOperationException(Xml_InvalidOperation); }
            }
        #endregion
        #region P:NamespaceResolver:IXmlNamespaceResolver
        // Get and set the namespace resolver that's used by this RawWriter to resolve prefixes.
        internal virtual IXmlNamespaceResolver NamespaceResolver
            {
            get
                {
                return resolver;
                }
            set
                {
                resolver = value;
                }
            }
        #endregion
        #region P:SupportsNamespaceDeclarationInChunks:Boolean
        // When true, the XmlWellFormedWriter will call:
        //      1) WriteStartNamespaceDeclaration
        //      2) any method that can be used to write out a value of an attribute: WriteString, WriteChars, WriteRaw, WriteCharEntity... 
        //      3) WriteEndNamespaceDeclaration
        // instead of just a single WriteNamespaceDeclaration call. 
        //
        // This feature will be supported by raw writers serializing to text that wish to preserve the attribute value escaping and entities.
        internal virtual Boolean SupportsNamespaceDeclarationInChunks
            {
            get
                {
                return false;
                }
            }
        #endregion

        #region M:WriteStartDocument
        /// <summary>Writes the XML declaration with the version "1.0".</summary>
        /// <exception cref="T:System.InvalidOperationException">This is not the first write method called after the constructor.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteStartDocument()
            {
            throw new InvalidOperationException(Xml_InvalidOperation);
            }
        #endregion
        #region M:WriteStartDocument(Boolean)
        /// <summary>Writes the XML declaration with the version "1.0" and the standalone attribute.</summary>
        /// <param name="standalone">If <see langword="true"/>, it writes "standalone=yes"; if <see langword="false"/>, it writes "standalone=no".</param>
        /// <exception cref="T:System.InvalidOperationException">This is not the first write method called after the constructor.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteStartDocument(Boolean standalone)
            {
            throw new InvalidOperationException(Xml_InvalidOperation);
            }
        #endregion
        #region M:WriteEndDocument
        /// <summary>Closes any open elements or attributes and puts the writer back in the <see cref="T:WriteState.Start"/> state.</summary>
        /// <exception cref="T:System.ArgumentException">The XML document is invalid.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteEndDocument()
            {
            throw new InvalidOperationException(Xml_InvalidOperation);
            }
        #endregion

        #if !SILVERLIGHT // This code is not being hit in Silverlight
        #region M:WriteDocType(String,String,String,String)
        /// <summary>Writes the DOCTYPE declaration with the specified name and optional attributes.</summary>
        /// <param name="name">The name of the DOCTYPE. This must be non-empty.</param>
        /// <param name="pubid">If non-null it also writes PUBLIC "pubid" "sysid" where <paramref name="pubid"/> and <paramref name="sysid"/> are replaced with the value of the given arguments.</param>
        /// <param name="sysid">If <paramref name="pubid"/> is <see langword="null"/> and <paramref name="sysid"/> is non-null it writes SYSTEM "sysid" where <paramref name="sysid"/> is replaced with the value of this argument.</param>
        /// <param name="subset">If non-null it writes [subset] where subset is replaced with the value of this argument.</param>
        /// <exception cref="T:System.InvalidOperationException">This method was called outside the prolog (after the root element). </exception>
        /// <exception cref="T:System.ArgumentException">The value for <paramref name="name"/> would result in invalid XML.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteDocType(String name,String pubid,String sysid,String subset)
            {
            }
        #endregion
        #endif
        #region M:WriteEndElement
        /// <summary>Closes one element and pops the corresponding namespace scope.</summary>
        /// <exception cref="T:System.InvalidOperationException">This results in an invalid XML document.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException" /> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteEndElement()
            {
            throw new InvalidOperationException(Xml_InvalidOperation);
            }
        #endregion
        #region M:WriteFullEndElement
        /// <summary>Closes one element and pops the corresponding namespace scope.</summary>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteFullEndElement()
            {
            throw new InvalidOperationException(Xml_InvalidOperation);
            }
        #endregion
        #region M:WriteBase64(Byte[],Int32,Int32)
        /// <summary>Encodes the specified binary bytes as Base64 and writes out the resulting text.</summary>
        /// <param name="buffer">Byte array to encode.</param>
        /// <param name="index">The position in the buffer indicating the start of the bytes to write.</param>
        /// <param name="count">The number of bytes to write.</param>
        /// <exception cref="T:System.ArgumentNullException"><paramref name="buffer"/> is <see langword="null"/>.</exception>
        /// <exception cref="T:System.ArgumentOutOfRangeException"><paramref name="index"/> or <paramref name="count"/> is less than zero. -or-The buffer length minus <paramref name="index"/> is less than <paramref name="count"/>.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteBase64(Byte[] buffer,Int32 index,Int32 count) {
            if (base64Encoder == null) {
                base64Encoder = new XmlRawWriterBase64Encoder(this);
                }
            // Encode will call WriteRaw to write out the encoded characters
            base64Encoder.Encode(buffer, index, count);
            }
        #endregion
        #region M:WriteNmToken(String)
        /// <summary>Writes out the specified name, ensuring it is a valid NmToken according to the W3C XML 1.0 recommendation (http://www.w3.org/TR/1998/REC-xml-19980210#NT-Name).</summary>
        /// <param name="name">The name to write.</param>
        /// <exception cref="T:System.ArgumentException"><paramref name="name"/> is not a valid NmToken; or <paramref name="name"/> is either <see langword="null"/> or <see langword="String.Empty"/>.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteNmToken(String name)
            {
            throw new InvalidOperationException(Xml_InvalidOperation);
            }
        #endregion
        #region M:WriteName(String)
        /// <summary>Writes out the specified name, ensuring it is a valid name according to the W3C XML 1.0 recommendation (http://www.w3.org/TR/1998/REC-xml-19980210#NT-Name).</summary>
        /// <param name="name">The name to write.</param>
        /// <exception cref="T:System.ArgumentException"><paramref name="name"/> is not a valid XML name; or <paramref name="name"/> is either <see langword="null"/> or <see langword="String.Empty"/>.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteName(String name)
            {
            throw new InvalidOperationException(Xml_InvalidOperation);
            }
        #endregion
        #region M:WriteQualifiedName(String,String)
        /// <summary>Writes out the namespace-qualified name. This method looks up the prefix that is in scope for the given namespace.</summary>
        /// <param name="localName">The local name to write.</param>
        /// <param name="ns">The namespace URI for the name.</param>
        /// <exception cref="T:System.ArgumentException"><paramref name="localName"/> is either <see langword="null"/> or <see langword="String.Empty"/>.
        /// <paramref name="localName"/> is not a valid name.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteQualifiedName(String localName,String ns)
            {
            throw new InvalidOperationException(Xml_InvalidOperation);
            }
        #endregion
        #region M:LookupPrefix(String):String
        /// <summary>Returns the closest prefix defined in the current namespace scope for the namespace URI.</summary>
        /// <param name="ns">The namespace URI whose prefix you want to find.</param>
        /// <returns>The matching prefix or <see langword="null" /> if no matching namespace URI is found in the current scope.</returns>
        /// <exception cref="T:System.ArgumentException"><paramref name="ns"/> is either <see langword="null"/> or <see langword="String.Empty"/>.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override String LookupPrefix(String ns)
            {
            throw new InvalidOperationException(Xml_InvalidOperation);
            }
        #endregion

        #if !SILVERLIGHT // This code is not being hit in Silverlight
        #region M:WriteCData(String)
        /// <summary>Writes out a &lt;![CDATA[...]]&gt; block containing the specified text.</summary>
        /// <param name="text">The text to place inside the CDATA block.</param>
        /// <exception cref="T:System.ArgumentException">The text would result in a non-well formed XML document.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteCData(String text)
            {
            WriteString(text);
            }
        #endregion
        #region M:WriteCharEntity(Char)
        /// <summary>Forces the generation of a character entity for the specified Unicode character value.</summary>
        /// <param name="ch">The Unicode character for which to generate a character entity.</param>
        /// <exception cref="T:System.ArgumentException">The character is in the surrogate pair character range, <see langword="0xd800"/> - <see langword="0xdfff"/>.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteCharEntity(Char ch)
            {
            WriteString(new String(new Char[] { ch }));
            }
        #endregion
        #region M:WriteSurrogateCharEntity(Char,Char)
        /// <summary>Generates and writes the surrogate character entity for the surrogate character pair.</summary>
        /// <param name="lowChar">The low surrogate. This must be a value between 0xDC00 and 0xDFFF.</param>
        /// <param name="highChar">The high surrogate. This must be a value between 0xD800 and 0xDBFF.</param>
        /// <exception cref="T:System.ArgumentException">An invalid surrogate character pair was passed.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteSurrogateCharEntity(Char lowChar,Char highChar)
            {
            WriteString(new String(new Char[] { lowChar, highChar }));
            }
        #endregion
        #region M:WriteWhitespace(String)
        /// <summary>Writes out the given white space.</summary>
        /// <param name="ws">The string of white space characters.</param>
        /// <exception cref="T:System.ArgumentException">The string contains non-white space characters.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteWhitespace(String ws)
            {
            WriteString(ws);
            }
        #endregion
        #region M:WriteChars(Char[],Int32,Int32)
        /// <summary>Writes text one buffer at a time.</summary>
        /// <param name="buffer">Character array containing the text to write.</param>
        /// <param name="index">The position in the buffer indicating the start of the text to write.</param>
        /// <param name="count">The number of characters to write.</param>
        /// <exception cref="T:System.ArgumentNullException"><paramref name="buffer"/> is <see langword="null"/>.</exception>
        /// <exception cref="T:System.ArgumentOutOfRangeException"><paramref name="index"/> or <paramref name="count"/> is less than zero.-or-The buffer length minus <paramref name="index" /> is less than <paramref name="count"/>; the call results in surrogate pair characters being split or an invalid surrogate pair being written.</exception>
        /// <exception cref="T:System.ArgumentException">The <paramref name="buffer"/> parameter value is not valid.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteChars(Char[] buffer,Int32 index,Int32 count)
            {
            WriteString(new String(buffer, index, count));
            }
        #endregion
        #region M:WriteRaw(Char[],Int32,Int32)
        /// <summary>Writes raw markup manually from a character buffer.</summary>
        /// <param name="buffer">Character array containing the text to write.</param>
        /// <param name="index">The position within the buffer indicating the start of the text to write.</param>
        /// <param name="count">The number of characters to write.</param>
        /// <exception cref="T:System.ArgumentNullException"><paramref name="buffer"/> is <see langword="null"/>.</exception>
        /// <exception cref="T:System.ArgumentOutOfRangeException"><paramref name="index"/> or <paramref name="count"/> is less than zero. -or-The buffer length minus <paramref name="index"/> is less than <paramref name="count"/>.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteRaw(Char[] buffer,Int32 index,Int32 count)
            {
            WriteString(new String(buffer, index, count));
            }
        #endregion
        #region M:WriteRaw(String)
        /// <summary>Writes raw markup manually from a string.</summary>
        /// <param name="data">String containing the text to write.</param>
        /// <exception cref="T:System.ArgumentException"><paramref name="data"/> is either <see langword="null"/> or <see langword="String.Empty"/>.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteRaw(String data)
            {
            WriteString(data);
            }
        #endregion
        #endif
        #region M:WriteValue(Object)
        /// <summary>Writes the object value.</summary>
        /// <param name="value">The object value to write.
        /// Note   With the release of the .NET Framework 3.5, this method accepts <see cref="T:System.DateTimeOffset" /> as a parameter.</param>
        /// <exception cref="T:System.ArgumentException">An invalid value was specified.</exception>
        /// <exception cref="T:System.ArgumentNullException">The <paramref name="value"/> is <see langword="null"/>.</exception>
        /// <exception cref="T:System.InvalidOperationException">The writer is closed or in error state.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteValue(Object value) {
            if (value == null) { throw new ArgumentNullException(nameof(value)); }
            #if SILVERLIGHT
            WriteString(XmlUntypedStringConverter.Instance.ToString( value, resolver ) );
            #else
            WriteString(value.ToString());
            #endif
            }
        #endregion
        #region M:WriteValue(String)
        /// <summary>Writes a <see cref="T:System.String"/> value.</summary>
        /// <param name="value">The <see cref="T:System.String"/> value to write.</param>
        /// <exception cref="T:System.ArgumentException">An invalid value was specified.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteValue(String value)
            {
            WriteString(value);
            }
        #endregion
        #region M:WriteValue(DateTimeOffset)
        /// <summary>Writes a <see cref="T:System.DateTimeOffset"/> value.</summary>
        /// <param name="value">The <see cref="T:System.DateTimeOffset"/> value to write.</param>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteValue(DateTimeOffset value)
            {
            // For compatibility with custom writers, XmlWriter writes DateTimeOffset as DateTime. 
            // Our internal writers should use the DateTimeOffset-String conversion from XmlConvert.
            WriteString(XmlConvert.ToString(value));
            }
        #endregion
        #region M:WriteAttributes(XmlReader,Boolean)
        /// <summary>Writes out all the attributes found at the current position in the <see cref="T:System.Xml.XmlReader"/>.</summary>
        /// <param name="reader">The <see langword="XmlReader"/> from which to copy the attributes.</param>
        /// <param name="defattr"><see langword="true"/> to copy the default attributes from the <see langword="XmlReader"/>; otherwise, <see langword="false"/>.</param>
        /// <exception cref="T:System.ArgumentNullException"><paramref name="reader"/> is <see langword="null"/>.</exception>
        /// <exception cref="T:System.Xml.XmlException">The reader is not positioned on an <see langword="element"/>, <see langword="attribute"/> or <see langword="XmlDeclaration"/> node.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteAttributes(XmlReader reader,Boolean defattr)
            {
            throw new InvalidOperationException(Xml_InvalidOperation);
            }
        #endregion
        #region M:WriteNode(XmlReader,Boolean)
        /// <summary>Copies everything from the reader to the writer and moves the reader to the start of the next sibling.</summary>
        /// <param name="reader">The <see cref="T:System.Xml.XmlReader"/> to read from.</param>
        /// <param name="defattr"><see langword="true"/> to copy the default attributes from the <see langword="XmlReader"/>; otherwise, <see langword="false"/>.</param>
        /// <exception cref="T:System.ArgumentNullException"><paramref name="reader"/> is <see langword="null"/>.</exception>
        /// <exception cref="T:System.ArgumentException"><paramref name="reader"/> contains invalid characters.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteNode(XmlReader reader,Boolean defattr)
            {
            throw new InvalidOperationException(Xml_InvalidOperation);
            }
        #endregion

        #if !SILVERLIGHT  // Removing dependency on XPathNavigator
        #region M:WriteNode(XPathNavigator,Boolean)
        /// <summary>Copies everything from the <see cref="T:System.Xml.XPath.XPathNavigator"/> object to the writer. The position of the <see cref="T:System.Xml.XPath.XPathNavigator"/> remains unchanged.</summary>
        /// <param name="navigator">The <see cref="T:System.Xml.XPath.XPathNavigator"/> to copy from.</param>
        /// <param name="defattr"><see langword="true"/> to copy the default attributes; otherwise, <see langword="false"/>.</param>
        /// <exception cref="T:System.ArgumentNullException"><paramref name="navigator"/> is <see langword="null"/>.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteNode(XPathNavigator navigator,Boolean defattr)
            {
            throw new InvalidOperationException(Xml_InvalidOperation);
            }
        #endregion
        #endif

        // Write the xml declaration.  This must be the first call.
        #if !SILVERLIGHT // This code is not being hit in Silverlight
        #region M:WriteXmlDeclaration(XmlStandalone)
        internal virtual void WriteXmlDeclaration(XmlStandalone standalone)
            {
            }
        #endregion
        #region M:WriteXmlDeclaration(String)
        internal virtual void WriteXmlDeclaration(String xmldecl)
            {
            }
        #endregion
        #else
        internal abstract void WriteXmlDeclaration(XmlStandalone standalone);
        internal abstract void WriteXmlDeclaration(String xmldecl);
        #endif

        /// <summary>
        /// Called after an element's attributes have been enumerated, but before any children have been
        /// enumerated. This method must always be called, even for empty elements.
        /// </summary>
        internal abstract void StartElementContent();

        #region M:OnRootElement(ConformanceLevel)
        /// <summary>Called before a root element is written (before the WriteStartElement call).</summary>
        /// <param name="conformanceLevel">Specifies the current conformance level the writer is operating with.</param>
        internal virtual void OnRootElement(ConformanceLevel conformanceLevel)
            {
            }
        #endregion

        /// <summary>Gives the full name of the element, so that raw writers do not need to keep a stack of element names.</summary>
        /// <param name="prefix">The namespace prefix of the element.</param>
        /// <param name="localName">The local name of the element.</param>
        /// <param name="ns">The namespace URI to associate with the element.</param>
        /// <remarks>This method should always be called instead of WriteEndElement() without parameters.</remarks>
        internal abstract void WriteEndElement(String prefix,String localName,String ns);

        #if !SILVERLIGHT // This code is not being hit in Silverlight
        #region M:WriteFullEndElement(String,String,String)
        /// <summary>Gives the full name of the element, so that raw writers do not need to keep a stack of element names.</summary>
        /// <param name="prefix">The namespace prefix of the element.</param>
        /// <param name="localName">The local name of the element.</param>
        /// <param name="ns">The namespace URI to associate with the element.</param>
        /// <remarks>This method should always be called instead of WriteFullEndElement() without parameters.</remarks>
        internal virtual void WriteFullEndElement(String prefix,String localName,String ns)
            {
            WriteEndElement(prefix,localName,ns);
            }
        #endregion
        #else
        internal abstract void WriteFullEndElement(String prefix,String localName,String ns);
        #endif

        #region M:WriteQualifiedName(String,String,String)
        internal virtual void WriteQualifiedName(String prefix,String localName,String ns) {
            if (prefix.Length != 0)
                {
                WriteString(prefix);
                WriteString(":");
                }
            WriteString(localName);
            }
        #endregion

        internal abstract void WriteNamespaceDeclaration(String prefix,String ns);

        #region M:WriteStartNamespaceDeclaration(String)
        internal virtual void WriteStartNamespaceDeclaration(String prefix)
            {
            throw new NotSupportedException();
            }
        #endregion
        #region M:WriteEndNamespaceDeclaration
        internal virtual void WriteEndNamespaceDeclaration()
            {
            throw new NotSupportedException();
            }
        #endregion
        #region M:WriteEndBase64
        // This is called when the remainder of a base64 value should be output.
        internal virtual void WriteEndBase64()
            {
            // The Flush will call WriteRaw to write out the rest of the encoded characters
            base64Encoder.Flush();
            }
        #endregion
        #region M:Close(WriteState)
        internal virtual void Close(WriteState currentState)
            {
            Close();
            }
        #endregion

        private const String Xml_InvalidOperation = "Operation is not valid due to the current state of the object.";
        }
    }