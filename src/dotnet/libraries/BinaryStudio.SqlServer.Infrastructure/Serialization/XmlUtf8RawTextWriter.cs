using System;
using System.Diagnostics;
using System.Diagnostics.CodeAnalysis;
using System.Globalization;
using System.IO;
using System.Text;
using System.Xml;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    // Concrete implementation of XmlWriter abstract class that serializes events as encoded XML
    // text.  The general-purpose XmlEncodedTextWriter uses the Encoder class to output to any
    // encoding.  The XmlUtf8TextWriter class combined the encoding operation with serialization
    // in order to achieve better performance.
    internal class XmlUtf8RawTextWriter : XmlRawWriter
        {
        #region P:DontThrowOnInvalidSurrogatePairs:Boolean
        public static Boolean DontThrowOnInvalidSurrogatePairs { get {
            var type = typeof(XmlWriter).Assembly.GetType("System.LocalAppContextSwitches");
            return (Boolean)type.GetProperty("DontThrowOnInvalidSurrogatePairs").GetValue(null);
            }}
        #endregion
        //
        // Fields
        //
        #if ASYNC
        private readonly bool useAsync;
        #endif

        // main buffer
        protected Byte[] bufBytes;

        // output stream
        protected Stream stream;

        // encoding of the stream or text writer 
        protected readonly Encoding encoding;

        // char type tables
        protected XmlCharType xmlCharType = XmlCharType.Instance;

        // buffer positions
        protected Int32 bufPos = 1;     // buffer position starts at 1, because we need to be able to safely step back -1 in case we need to
                                      // close an empty element or in CDATA section detection of double ]; _BUFFER[0] will always be 0
        protected Int32 textPos = 1;    // text end position; don't indent first element, pi, or comment
        protected Int32 contentPos;     // element content end position
        protected Int32 cdataPos;       // cdata end position
        protected Int32 attrEndPos;     // end of the last attribute
        protected readonly Int32 bufLen = BUFSIZE;

        // flags
        protected Boolean writeToNull;
        protected Boolean hadDoubleBracket;
        protected Boolean inAttributeValue;

        protected NewLineHandling NewLineHandling { get; }
        protected String NewLineChars { get; }
        protected Boolean CloseOutput { get; }
        protected Boolean OmitXmlDeclaration { get; }
        protected Boolean CheckCharacters { get; }
        protected Boolean AutoXmlDeclaration { get; }
        protected Boolean MergeCDataSections { get; }
        protected XmlStandalone Standalone { get; }
        #if !SILVERLIGHT
        protected XmlOutputMethod OutputMethod { get; }
        #endif

        private const Int32 BUFSIZE = 2048 * 3;       // Should be greater than default FileStream size (4096), otherwise the FileStream will try to cache the data
        private const Int32 ASYNCBUFSIZE = 64 * 1024; // Set async buffer size to 64KB
        private const Int32 OVERFLOW = 32;            // Allow overflow in order to reduce checks when writing out constant size markup
        private const Int32 INIT_MARKS_COUNT = 64;

        #region ctor{XmlWriterSettings}
        // Construct and initialize an instance of this class.
        protected XmlUtf8RawTextWriter(XmlWriterSettings settings)
            {
            #if ASYNC
            useAsync = settings.Async;
            #endif

            // copy settings
            NewLineHandling = settings.NewLineHandling;
            OmitXmlDeclaration = settings.OmitXmlDeclaration;
            NewLineChars = settings.NewLineChars;
            CheckCharacters = settings.CheckCharacters;
            CloseOutput = settings.CloseOutput;

            #if !SILVERLIGHT
            Standalone = settings.Standalone();
            OutputMethod = settings.OutputMethod;
            MergeCDataSections = settings.MergeCDataSections();
            #endif

            if (CheckCharacters && NewLineHandling == NewLineHandling.Replace)
                {
                ValidateContentChars(NewLineChars, "NewLineChars", false);
                }
            }
        #endregion
        #region ctor{Stream,XmlWriterSettings}
        // Construct an instance of this class that serializes to a Stream interface.
        [SuppressMessage("ReSharper", "VirtualMemberCallInConstructor")]
        [SuppressMessage("ReSharper", "ArrangeThisQualifier")]
        public XmlUtf8RawTextWriter(Stream stream,XmlWriterSettings settings)
            :this(settings)
            {
            Debug.Assert(stream != null && settings != null);

            this.stream = stream;
            this.encoding = settings.Encoding;

            // the buffer is allocated will OVERFLOW in order to reduce checks when writing out constant size markup
            if (settings.Async)
                {
                bufLen = ASYNCBUFSIZE;
                }

            bufBytes = new Byte[bufLen + OVERFLOW];

            // Output UTF-8 byte order mark if Encoding object wants it
            if (!stream.CanSeek || stream.Position == 0) {
                var bom = encoding.GetPreamble();
                if (bom.Length != 0) {
                    Buffer.BlockCopy(bom, 0, bufBytes, 1, bom.Length);
                    bufPos += bom.Length;
                    textPos += bom.Length;
                    }
                }

            #if !SILVERLIGHT
            // Write the xml declaration
            if (settings.AutoXmlDeclaration())
                {
                WriteXmlDeclaration(Standalone);
                AutoXmlDeclaration = true;
                }
            #endif
            }
        #endregion

        #region P:Settings:XmlWriterSettings
        // Returns settings the writer currently applies.
        public override XmlWriterSettings Settings { get {
            var settings = new XmlWriterSettings
                {
                Encoding = encoding,
                OmitXmlDeclaration = OmitXmlDeclaration,
                NewLineHandling = NewLineHandling,
                NewLineChars = NewLineChars,
                CloseOutput = CloseOutput,
                ConformanceLevel = ConformanceLevel.Auto,
                CheckCharacters = CheckCharacters
                };

            #if !SILVERLIGHT
            settings.AutoXmlDeclaration(AutoXmlDeclaration);
            settings.Standalone(Standalone);
            settings.OutputMethod(OutputMethod);
            #endif

            settings.ReadOnly(true);
            return settings;
            }}
        #endregion
        #region P:SupportsNamespaceDeclarationInChunks:Boolean
        internal override Boolean SupportsNamespaceDeclarationInChunks
            {
            get
                {
                return true;
                }
            }
        #endregion

        #region M:WriteXmlDeclaration(XmlStandalone)
        // Write the xml declaration. This must be the first call.
        internal override void WriteXmlDeclaration(XmlStandalone standalone) {
            // Output xml declaration only if user allows it and it was not already output
            if (!OmitXmlDeclaration && !AutoXmlDeclaration) {
                RawText("<?xml version=\"");
                // Version
                RawText("1.0");

                // Encoding
                if (encoding != null)
                    {
                    RawText("\" encoding=\"");
                    RawText(encoding.WebName);
                    }

                // Standalone
                if (standalone != XmlStandalone.Omit)
                    {
                    RawText("\" standalone=\"");
                    RawText(standalone == XmlStandalone.Yes ? "yes" : "no");
                    }

                RawText("\"?>");
                }
            }
        #endregion
        #region M:WriteXmlDeclaration(String)
        internal override void WriteXmlDeclaration(String xmldecl) {
            // Output xml declaration only if user allows it and it was not already output
            if (!OmitXmlDeclaration && !AutoXmlDeclaration)
                {
                WriteProcessingInstruction("xml",xmldecl);
                }
            }
        #endregion
        #region M:WriteDocType(String,String,String,String)
        /// <summary>Writes the DOCTYPE declaration with the specified name and optional attributes.</summary>
        /// <param name="name">The name of the DOCTYPE. This must be non-empty.</param>
        /// <param name="pubid">If non-null it also writes PUBLIC "pubid" "sysid" where <paramref name="pubid"/> and <paramref name="sysid"/> are replaced with the value of the given arguments.</param>
        /// <param name="sysid">If <paramref name="pubid" /> is <see langword="null" /> and <paramref name="sysid"/> is non-null it writes SYSTEM "sysid" where <paramref name="sysid"/> is replaced with the value of this argument.</param>
        /// <param name="subset">If non-null it writes [subset] where subset is replaced with the value of this argument.</param>
        /// <exception cref="T:System.InvalidOperationException">This method was called outside the prolog (after the root element). </exception>
        /// <exception cref="T:System.ArgumentException">The value for <paramref name="name"/> would result in invalid XML.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteDocType(String name,String pubid,String sysid,String subset) {
            Debug.Assert(!String.IsNullOrEmpty(name));
            RawText("<!DOCTYPE ");
            RawText(name);
            if (pubid != null) {
                RawText(" PUBLIC \"");
                RawText(pubid);
                RawText("\" \"");
                if (sysid != null)
                    {
                    RawText(sysid);
                    }
                bufBytes[bufPos++] = (Byte)'"';
                }
            else if (sysid != null)
                {
                RawText(" SYSTEM \"");
                RawText(sysid);
                bufBytes[bufPos++] = (Byte)'"';
                }
            else
                {
                bufBytes[bufPos++] = (Byte)' ';
                }

            if (subset != null)
                {
                bufBytes[bufPos++] = (Byte)'[';
                RawText(subset);
                bufBytes[bufPos++] = (Byte)']';
                }

            bufBytes[bufPos++] = (Byte)'>';
            }
        #endregion
        #region M:WriteStartElement(String,String,String)
        /// <summary>Writes the specified start tag and associates it with the given namespace and prefix.</summary>
        /// <param name="prefix">The namespace prefix of the element.</param>
        /// <param name="localName">The local name of the element.</param>
        /// <param name="ns">The namespace URI to associate with the element.</param>
        /// <exception cref="T:System.InvalidOperationException">The writer is closed.</exception>
        /// <exception cref="T:System.Text.EncoderFallbackException">There is a character in the buffer that is a valid XML character but is not valid for the output encoding. For example, if the output encoding is ASCII, you should only use characters from the range of 0 to 127 for element and attribute names. The invalid character might be in the argument of this method or in an argument of previous methods that were writing to the buffer. Such characters are escaped by character entity references when possible (for example, in text nodes or attribute values). However, the character entity reference is not allowed in element and attribute names, comments, processing instructions, or CDATA sections.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        /// <remarks>Serialize the beginning of an element start tag: "&lt;prefix:localName"</remarks>
        public override void WriteStartElement(String prefix,String localName,String ns) {
            Debug.Assert(!String.IsNullOrEmpty(localName));
            Debug.Assert(prefix != null);

            bufBytes[bufPos++] = (Byte)'<';
            if (!String.IsNullOrEmpty(prefix)) {
                RawText(prefix);
                bufBytes[bufPos++] = (Byte)':';
                }

            RawText(localName);
            attrEndPos = bufPos;
            }
        #endregion
        #region M:StartElementContent
        /// <summary>
        /// Serialize the end of an element start tag in preparation for content serialization: ">"
        /// </summary>
        internal override void StartElementContent()
            {
            bufBytes[bufPos++] = (Byte)'>';

            // StartElementContent is always called; therefore, in order to allow shortcut syntax, we save the
            // position of the '>' character.  If WriteEndElement is called and no other characters have been
            // output, then the '>' character can be be overwritten with the shortcut syntax " />".
            contentPos = bufPos;
            }
        #endregion
        #region M:WriteEndElement(String,String,String)
        /// <summary>Serialize an element end tag: "&lt;/prefix:localName&gt;", if content was output.  Otherwise, serialize the shortcut syntax: " /&gt;".</summary>
        /// <param name="prefix">The namespace prefix of the element.</param>
        /// <param name="localName">The local name of the element.</param>
        /// <param name="ns">The namespace URI to associate with the element.</param>
        /// <remarks>This method should always be called instead of WriteEndElement() without parameters.</remarks>
        internal override void WriteEndElement(String prefix,String localName,String ns) {
            Debug.Assert(!String.IsNullOrEmpty(localName));
            Debug.Assert(prefix != null);

            if (contentPos != bufPos) {
                // Content has been output, so can't use shortcut syntax
                bufBytes[bufPos++] = (Byte)'<';
                bufBytes[bufPos++] = (Byte)'/';

                if (!String.IsNullOrEmpty(prefix)) {
                    RawText(prefix);
                    bufBytes[bufPos++] = (Byte)':';
                    }
                RawText(localName);
                bufBytes[bufPos++] = (Byte)'>';
                }
            else
                {
                // Use shortcut syntax; overwrite the already output '>' character
                bufPos--;
                bufBytes[bufPos++] = (Byte)' ';
                bufBytes[bufPos++] = (Byte)'/';
                bufBytes[bufPos++] = (Byte)'>';
                }
            }
        #endregion
        #region M:WriteFullEndElement(String,String,String)
        /// <summary>Serialize a full element end tag: "&lt;/prefix:localName&gt;"</summary>
        /// <param name="prefix">The namespace prefix of the element.</param>
        /// <param name="localName">The local name of the element.</param>
        /// <param name="ns">The namespace URI to associate with the element.</param>
        /// <remarks>This method should always be called instead of WriteFullEndElement() without parameters.</remarks>
        internal override void WriteFullEndElement(String prefix,String localName,String ns) {
            Debug.Assert(!String.IsNullOrEmpty(localName));
            Debug.Assert(prefix != null);

            bufBytes[bufPos++] = (Byte)'<';
            bufBytes[bufPos++] = (Byte)'/';

            if (!String.IsNullOrEmpty(prefix)) {
                RawText(prefix);
                bufBytes[bufPos++] = (Byte)':';
                }
            RawText(localName);
            bufBytes[bufPos++] = (Byte)'>';
            }
        #endregion
        #region M:WriteStartAttribute(String,String,String)
        /// <summary>Writes the start of an attribute with the specified prefix, local name, and namespace URI.</summary>
        /// <param name="prefix">The namespace prefix of the attribute.</param>
        /// <param name="localName">The local name of the attribute.</param>
        /// <param name="ns">The namespace URI for the attribute.</param>
        /// <exception cref="T:System.Text.EncoderFallbackException">There is a character in the buffer that is a valid XML character but is not valid for the output encoding. For example, if the output encoding is ASCII, you should only use characters from the range of 0 to 127 for element and attribute names. The invalid character might be in the argument of this method or in an argument of previous methods that were writing to the buffer. Such characters are escaped by character entity references when possible (for example, in text nodes or attribute values). However, the character entity reference is not allowed in element and attribute names, comments, processing instructions, or CDATA sections.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter" /> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        /// <remarks>Serialize an attribute tag using double quotes around the attribute value: 'prefix:localName="'</remarks>
        public override void WriteStartAttribute(String prefix, String localName, String ns)
            {
            Debug.Assert(!String.IsNullOrEmpty(localName));
            Debug.Assert(prefix != null);

            if (attrEndPos == bufPos)
                {
                bufBytes[bufPos++] = (Byte)' ';
                }

            if (!String.IsNullOrEmpty(prefix)) {
                RawText(prefix);
                bufBytes[bufPos++] = (Byte)':';
                }
            RawText(localName);
            bufBytes[bufPos++] = (Byte)'=';
            bufBytes[bufPos++] = (Byte)'"';

            inAttributeValue = true;
            }
        #endregion
        #region M:WriteEndAttribute
        /// <summary>Closes the previous <see cref="M:System.Xml.XmlWriter.WriteStartAttribute(System.String,System.String)"/> call.</summary>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        /// <remarks>Serialize the end of an attribute value using double quotes: '"'</remarks>
        public override void WriteEndAttribute()
            {
            bufBytes[bufPos++] = (Byte)'"';
            inAttributeValue = false;
            attrEndPos = bufPos;
            }
        #endregion
        #region M:WriteNamespaceDeclaration(String,String)
        internal override void WriteNamespaceDeclaration(String prefix,String namespaceName)
            {
            Debug.Assert(prefix != null && namespaceName != null);

            WriteStartNamespaceDeclaration(prefix);
            WriteString(namespaceName);
            WriteEndNamespaceDeclaration();
            }
        #endregion
        #region M:WriteStartNamespaceDeclaration(String)
        internal override void WriteStartNamespaceDeclaration(String prefix) {
            Debug.Assert(prefix != null);
            // VSTFDEVDIV bug #583965: Inconsistency between Silverlight 2 and Dev10 in the way a single xmlns attribute is serialized    
            // Resolved as: Won't fix (breaking change)
            if (prefix.Length == 0)
                {
                RawText(" xmlns=\"");
                }
            else
                {
                RawText(" xmlns:");
                RawText(prefix);
                bufBytes[bufPos++] = (Byte)'=';
                bufBytes[bufPos++] = (Byte)'"';
                }
            inAttributeValue = true;
            }
        #endregion
        #region M:WriteEndNamespaceDeclaration
        internal override void WriteEndNamespaceDeclaration()
            {
            inAttributeValue = false;
            bufBytes[bufPos++] = (Byte)'"';
            attrEndPos = bufPos;
            }
        #endregion
        #region M:WriteCData(String)
        /// <summary>Writes out a &lt;![CDATA[...]]&gt; block containing the specified text.</summary>
        /// <param name="text">The text to place inside the CDATA block.</param>
        /// <exception cref="T:System.ArgumentException">The text would result in a non-well formed XML document.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        /// <remarks>Serialize a CData section. If the "]]&gt;" pattern is found within the text, replace it with "]]&gt;&lt;![CDATA[&gt;".</remarks>
        public override void WriteCData(String text) {
            Debug.Assert(text != null);
            if (MergeCDataSections && bufPos == cdataPos) {
                // Merge adjacent cdata sections - overwrite the "]]>" characters
                Debug.Assert(bufPos >= 4);
                bufPos -= 3;
                }
            else
                {
                // Start a new cdata section
                bufBytes[bufPos++] = (Byte)'<';
                bufBytes[bufPos++] = (Byte)'!';
                bufBytes[bufPos++] = (Byte)'[';
                bufBytes[bufPos++] = (Byte)'C';
                bufBytes[bufPos++] = (Byte)'D';
                bufBytes[bufPos++] = (Byte)'A';
                bufBytes[bufPos++] = (Byte)'T';
                bufBytes[bufPos++] = (Byte)'A';
                bufBytes[bufPos++] = (Byte)'[';
                }

            WriteCDataSection(text);

            bufBytes[bufPos++] = (Byte)']';
            bufBytes[bufPos++] = (Byte)']';
            bufBytes[bufPos++] = (Byte)'>';

            textPos = bufPos;
            cdataPos = bufPos;
            }
        #endregion
        #region M:WriteComment(String)
        /// <summary>Writes out a comment &lt;!--...--&gt; containing the specified text.</summary>
        /// <param name="text">Text to place inside the comment.</param>
        /// <exception cref="T:System.ArgumentException">The text would result in a non-well-formed XML document.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteComment(String text)
            {
            Debug.Assert(text != null);

            bufBytes[bufPos++] = (Byte)'<';
            bufBytes[bufPos++] = (Byte)'!';
            bufBytes[bufPos++] = (Byte)'-';
            bufBytes[bufPos++] = (Byte)'-';

            WriteCommentOrPi(text, '-');

            bufBytes[bufPos++] = (Byte)'-';
            bufBytes[bufPos++] = (Byte)'-';
            bufBytes[bufPos++] = (Byte)'>';
            }
        #endregion
        #region M:WriteProcessingInstruction(String,String)
        /// <summary>When overridden in a derived class, writes out a processing instruction with a space between the name and text as follows: &lt;?name text?&gt;.</summary>
        /// <param name="name">The name of the processing instruction.</param>
        /// <param name="text">The text to include in the processing instruction.</param>
        /// <exception cref="T:System.ArgumentException">The text would result in a non-well formed XML document. <paramref name="name"/> is either <see langword="null"/> or <see langword="String.Empty"/>.This method is being used to create an XML declaration after <see cref="M:System.Xml.XmlWriter.WriteStartDocument"/> has already been called.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteProcessingInstruction(String name,String text) {
            Debug.Assert(!String.IsNullOrEmpty(name));
            Debug.Assert(text != null);

            bufBytes[bufPos++] = (Byte)'<';
            bufBytes[bufPos++] = (Byte)'?';
            RawText(name);

            if (text.Length > 0)
                {
                bufBytes[bufPos++] = (Byte)' ';
                WriteCommentOrPi(text, '?');
                }

            bufBytes[bufPos++] = (Byte)'?';
            bufBytes[bufPos++] = (Byte)'>';
            }
        #endregion
        #region M:WriteEntityRef(String)
        /// <summary>Writes out an entity reference as <see langword="&amp;name;" />.</summary>
        /// <param name="name">The name of the entity reference.</param>
        /// <exception cref="T:System.ArgumentException"><paramref name="name"/> is either <see langword="null"/> or <see langword="String.Empty"/>.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteEntityRef(String name) {
            Debug.Assert(!String.IsNullOrEmpty(name));
            bufBytes[bufPos++] = (Byte)'&';
            RawText(name);
            bufBytes[bufPos++] = (Byte)';';
            if (bufPos > bufLen)
                {
                FlushBuffer();
                }
            textPos = bufPos;
            }
        #endregion
        #region M:WriteCharEntity(Char)
        /// <summary>Forces the generation of a character entity for the specified Unicode character value.</summary>
        /// <param name="ch">The Unicode character for which to generate a character entity.</param>
        /// <exception cref="T:System.ArgumentException">The character is in the surrogate pair character range, <see langword="0xd800"/> - <see langword="0xdfff"/>.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteCharEntity(Char ch) {
            var strVal = ((Int32)ch).ToString("X", NumberFormatInfo.InvariantInfo);
            if (CheckCharacters && !xmlCharType.IsCharData(ch))
                {
                // we just have a single char, not a surrogate, therefore we have to pass in '\0' for the second char
                throw XmlExceptions.CreateInvalidCharException(ch, '\0');
                }

            bufBytes[bufPos++] = (Byte)'&';
            bufBytes[bufPos++] = (Byte)'#';
            bufBytes[bufPos++] = (Byte)'x';
            RawText(strVal);
            bufBytes[bufPos++] = (Byte)';';

            if (bufPos > bufLen)
                {
                FlushBuffer();
                }

            textPos = bufPos;
            }
        #endregion
        #region M:WriteWhitespace(String)
        /// <summary>Writes out the given white space.</summary>
        /// <param name="ws">The string of white space characters.</param>
        /// <exception cref="T:System.ArgumentException">The string contains non-white space characters.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override unsafe void WriteWhitespace(String ws) {
            Debug.Assert(ws != null);
            fixed (Char* pSrc = ws) {
                var pSrcEnd = pSrc + ws.Length;
                if (inAttributeValue)
                    {
                    WriteAttributeTextBlock(pSrc, pSrcEnd);
                    }
                else
                    {
                    WriteElementTextBlock(pSrc, pSrcEnd);
                    }
                }
            }
        #endregion
        #region M:WriteString(String)
        /// <summary>Writes the given text content.</summary>
        /// <param name="text">The text to write.</param>
        /// <exception cref="T:System.ArgumentException">The text string contains an invalid surrogate pair.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        /// <remarks>Serialize either attribute or element text using XML rules.</remarks>
        public override unsafe void WriteString(String text) {
            Debug.Assert(text != null);
            fixed (Char* pSrc = text) {
                var pSrcEnd = pSrc + text.Length;
                if (inAttributeValue)
                    {
                    WriteAttributeTextBlock(pSrc, pSrcEnd);
                    }
                else
                    {
                    WriteElementTextBlock(pSrc, pSrcEnd);
                    }
                }
            }
        #endregion
        #region M:WriteSurrogateCharEntity(Char,Char)
        /// <summary>Generates and writes the surrogate character entity for the surrogate character pair.</summary>
        /// <param name="lowChar">The low surrogate. This must be a value between 0xDC00 and 0xDFFF.</param>
        /// <param name="highChar">The high surrogate. This must be a value between 0xD800 and 0xDBFF.</param>
        /// <exception cref="T:System.ArgumentException">An invalid surrogate character pair was passed.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteSurrogateCharEntity(Char lowChar,Char highChar) {
            var surrogateChar = XmlCharType.CombineSurrogateChar(lowChar,highChar);
            bufBytes[bufPos++] = (Byte)'&';
            bufBytes[bufPos++] = (Byte)'#';
            bufBytes[bufPos++] = (Byte)'x';
            RawText(surrogateChar.ToString("X", NumberFormatInfo.InvariantInfo));
            bufBytes[bufPos++] = (Byte)';';
            textPos = bufPos;
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
        /// <remarks>
        /// Serialize either attribute or element text using XML rules.
        /// Arguments are validated in the XmlWellformedWriter layer.
        /// </remarks>
        public override unsafe void WriteChars(Char[] buffer,Int32 index,Int32 count)
            {
            Debug.Assert(buffer != null);
            Debug.Assert(index >= 0);
            Debug.Assert(count >= 0 && index + count <= buffer.Length);

            fixed (Char* pSrcBegin = &buffer[index]) {
                if (inAttributeValue)
                    {
                    WriteAttributeTextBlock(pSrcBegin, pSrcBegin + count);
                    }
                else
                    {
                    WriteElementTextBlock(pSrcBegin, pSrcBegin + count);
                    }
                }
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
        /// <remarks>
        /// Serialize raw data.
        /// Arguments are validated in the XmlWellformedWriter layer.
        /// </remarks>
        public override unsafe void WriteRaw(Char[] buffer,Int32 index,Int32 count) {
            Debug.Assert(buffer != null);
            Debug.Assert(index >= 0);
            Debug.Assert(count >= 0 && index + count <= buffer.Length);
            fixed (Char* pSrcBegin = &buffer[index]) {
                WriteRawWithCharChecking(pSrcBegin, pSrcBegin + count);
                }
            textPos = bufPos;
            }
        #endregion
        #region M:WriteRaw(String)
        /// <summary>Writes raw markup manually from a string.</summary>
        /// <param name="data">String containing the text to write.</param>
        /// <exception cref="T:System.ArgumentException"><paramref name="data"/> is either <see langword="null"/> or <see langword="String.Empty"/>.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override unsafe void WriteRaw(String data) {
            Debug.Assert(data != null);
            fixed (Char* pSrcBegin = data) {
                WriteRawWithCharChecking(pSrcBegin, pSrcBegin + data.Length);
                }
            textPos = bufPos;
            }
        #endregion
        #region M:Close
        // Flush all bytes in the buffer to output and close the output stream or writer.
        public override void Close()
            {
            try
                {
                FlushBuffer();
                FlushEncoder();
                }
            finally
                {
                // Future calls to Close or Flush shouldn't write to Stream or Writer
                writeToNull = true;

                if (stream != null)
                    {
                    try
                        {
                        stream.Flush();
                        }
                    finally
                        {
                        try
                            {
                            if (CloseOutput)
                                {
                                stream.Close();
                                }
                            }
                        finally
                            {
                            stream = null;
                            }
                        }
                    }

                }
            }
        #endregion
        #region M:Flush
        /// <summary>When overridden in a derived class, flushes whatever is in the buffer to the underlying streams and also flushes the underlying stream.</summary>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        /// <remarks>Flush all characters in the buffer to output and call Flush() on the output object.</remarks>
        public override void Flush() {
            FlushBuffer();
            FlushEncoder();
            stream?.Flush();
            }
        #endregion
        #region M:FlushBuffer
        // Flush all characters in the buffer to output.  Do not flush the output object.
        protected virtual void FlushBuffer()
            {
            try
                {
                // Output all characters (except for previous characters stored at beginning of buffer)
                if (!writeToNull)
                    {

                    Debug.Assert(stream != null);
                    stream.Write(bufBytes, 1, bufPos - 1);

                    }
                }
            catch
                {
                // Future calls to flush (i.e. when Close() is called) don't attempt to write to stream
                writeToNull = true;
                throw;
                }
            finally
                {
                // Move last buffer character to the beginning of the buffer (so that previous character can always be determined)
                bufBytes[0] = bufBytes[bufPos - 1];

                if (IsSurrogateByte(bufBytes[0]))
                    {
                    // Last character was the first byte in a surrogate encoding, so move last three
                    // bytes of encoding to the beginning of the buffer.
                    bufBytes[1] = bufBytes[bufPos];
                    bufBytes[2] = bufBytes[bufPos + 1];
                    bufBytes[3] = bufBytes[bufPos + 2];
                    }

                // Reset buffer position
                textPos = (textPos == bufPos) ? 1 : 0;
                attrEndPos = (attrEndPos == bufPos) ? 1 : 0;
                contentPos = 0;    // Needs to be zero, since overwriting '>' character is no longer possible
                cdataPos = 0;      // Needs to be zero, since overwriting ']]>' characters is no longer possible
                bufPos = 1;        // Buffer position starts at 1, because we need to be able to safely step back -1 in case we need to
                                   // close an empty element or in CDATA section detection of double ]; _BUFFER[0] will always be 0
                }
            }
        #endregion
        #region M:FlushEncoder
        private void FlushEncoder()
            {
            // intentionally empty

            }
        #endregion
        #region M:WriteAttributeTextBlock(Char*,Char*)
        // Serialize text that is part of an attribute value.  The '&', '<', '>', and '"' characters
        // are entitized.
        protected unsafe void WriteAttributeTextBlock(Char* pSrc,Char* pSrcEnd) {
            fixed (Byte* pDstBegin = bufBytes) {
                var pDst = pDstBegin + bufPos;
                var ch = 0;
                for (;;) {
                    var pDstEnd = pDst + (pSrcEnd - pSrc);
                    if (pDstEnd > pDstBegin + bufLen)
                        {
                        pDstEnd = pDstBegin + bufLen;
                        }

                    while (pDst < pDstEnd && (((xmlCharType.charProperties[(ch = *pSrc)] & XmlCharType.fAttrValue) != 0) && ch <= 0x7F))
                        {
                        *pDst = (Byte)ch;
                        pDst++;
                        pSrc++;
                        }
                    Debug.Assert(pSrc <= pSrcEnd);

                    // end of value
                    if (pSrc >= pSrcEnd)
                        {
                        break;
                        }

                    // end of buffer
                    if (pDst >= pDstEnd)
                        {
                        bufPos = (Int32)(pDst - pDstBegin);
                        FlushBuffer();
                        pDst = pDstBegin + 1;
                        continue;
                        }

                    // some character needs to be escaped
                    switch (ch)
                        {
                        case '&':
                            pDst = AmpEntity(pDst);
                            break;
                        case '<':
                            pDst = LtEntity(pDst);
                            break;
                        case '>':
                            pDst = GtEntity(pDst);
                            break;
                        case '"':
                            pDst = QuoteEntity(pDst);
                            break;
                        case '\'':
                            *pDst = (Byte)ch;
                            pDst++;
                            break;
                        case (Char)0x9:
                            if (NewLineHandling == NewLineHandling.None)
                                {
                                *pDst = (Byte)ch;
                                pDst++;
                                }
                            else
                                {
                                // escape tab in attributes
                                pDst = TabEntity(pDst);
                                }
                            break;
                        case (Char)0xD:
                            if (NewLineHandling == NewLineHandling.None)
                                {
                                *pDst = (Byte)ch;
                                pDst++;
                                }
                            else
                                {
                                // escape new lines in attributes
                                pDst = CarriageReturnEntity(pDst);
                                }
                            break;
                        case (Char)0xA:
                            if (NewLineHandling == NewLineHandling.None)
                                {
                                *pDst = (Byte)ch;
                                pDst++;
                                }
                            else
                                {
                                // escape new lines in attributes
                                pDst = LineFeedEntity(pDst);
                                }
                            break;
                        default:
                                 if (XmlCharType.IsSurrogate(ch)) { pDst = EncodeSurrogate(pSrc, pSrcEnd, pDst); pSrc += 2; }
                            else if (ch <= 0x7F || ch >= 0xFFFE) { pDst = InvalidXmlChar(ch, pDst, true); pSrc++; }
                            else { pDst = EncodeMultibyteUTF8(ch, pDst); pSrc++; }
                            continue;
                        }
                    pSrc++;
                    }
                bufPos = (Int32)(pDst - pDstBegin);
                }
            }
        #endregion
        #region M:WriteElementTextBlock(Char*,Char*)
        // Serialize text that is part of element content.  The '&', '<', and '>' characters
        // are entitized.
        protected unsafe void WriteElementTextBlock(Char* pSrc,Char* pSrcEnd) {
            fixed (Byte* pDstBegin = bufBytes) {
                var pDst = pDstBegin + bufPos;
                var ch = 0;
                for (;;) {
                    var pDstEnd = pDst + (pSrcEnd - pSrc);
                    if (pDstEnd > pDstBegin + bufLen)
                        {
                        pDstEnd = pDstBegin + bufLen;
                        }

                    while (pDst < pDstEnd && (((xmlCharType.charProperties[(ch = *pSrc)] & XmlCharType.fAttrValue) != 0) && ch <= 0x7F))
                        {
                        *pDst = (Byte)ch;
                        pDst++;
                        pSrc++;
                        }
                    Debug.Assert(pSrc <= pSrcEnd);

                    // end of value
                    if (pSrc >= pSrcEnd)
                        {
                        break;
                        }

                    // end of buffer
                    if (pDst >= pDstEnd)
                        {
                        bufPos = (Int32)(pDst - pDstBegin);
                        FlushBuffer();
                        pDst = pDstBegin + 1;
                        continue;
                        }

                    // some character needs to be escaped
                    switch (ch)
                        {
                        case '&':
                            pDst = AmpEntity(pDst);
                            break;
                        case '<':
                            pDst = LtEntity(pDst);
                            break;
                        case '>':
                            pDst = GtEntity(pDst);
                            break;
                        case '"':
                        case '\'':
                        case (Char)0x9:
                            *pDst = (Byte)ch;
                            pDst++;
                            break;
                        case (Char)0xA:
                            if (NewLineHandling == NewLineHandling.Replace)
                                {
                                pDst = WriteNewLine(pDst);
                                }
                            else
                                {
                                *pDst = (Byte)ch;
                                pDst++;
                                }
                            break;
                        case (Char)0xD:
                            switch (NewLineHandling)
                                {
                                case NewLineHandling.Replace:
                                    // Replace "\r\n", or "\r" with NewLineChars
                                    if (pSrc[1] == '\n')
                                        {
                                        pSrc++;
                                        }

                                    pDst = WriteNewLine(pDst);
                                    break;

                                case NewLineHandling.Entitize:
                                    // Entitize 0xD
                                    pDst = CarriageReturnEntity(pDst);
                                    break;
                                case NewLineHandling.None:
                                    *pDst = (Byte)ch;
                                    pDst++;
                                    break;
                                }
                            break;
                        default:
                                 if (XmlCharType.IsSurrogate(ch)) { pDst = EncodeSurrogate(pSrc, pSrcEnd, pDst); pSrc += 2; }
                            else if (ch <= 0x7F || ch >= 0xFFFE) { pDst = InvalidXmlChar(ch, pDst, true); pSrc++; }
                            else { pDst = EncodeMultibyteUTF8(ch, pDst); pSrc++; }
                            continue;
                        }
                    pSrc++;
                    }
                bufPos = (Int32)(pDst - pDstBegin);
                textPos = bufPos;
                contentPos = 0;
                }
            }
        #endregion
        #region M:RawText(String)
        protected unsafe void RawText(String s) {
            Debug.Assert(s != null);
            fixed (Char* pSrcBegin = s)
                {
                RawText(pSrcBegin,pSrcBegin + s.Length);
                }
            }
        #endregion
        #region M:RawText(Char*,Char*)
        protected unsafe void RawText(Char* pSrcBegin,Char* pSrcEnd) {
            fixed (Byte* pDstBegin = bufBytes) {
                var pDst = pDstBegin + bufPos;
                var pSrc = pSrcBegin;

                var ch = 0;
                for (;;) {
                    var pDstEnd = pDst + (pSrcEnd - pSrc);
                    if (pDstEnd > pDstBegin + bufLen)
                        {
                        pDstEnd = pDstBegin + bufLen;
                        }

                    while (pDst < pDstEnd && ((ch = *pSrc) <= 0x7F))
                        {
                        pSrc++;
                        *pDst = (Byte)ch;
                        pDst++;
                        }
                    Debug.Assert(pSrc <= pSrcEnd);

                    // end of value
                    if (pSrc >= pSrcEnd)
                        {
                        break;
                        }

                    // end of buffer
                    if (pDst >= pDstEnd)
                        {
                        bufPos = (Int32)(pDst - pDstBegin);
                        FlushBuffer();
                        pDst = pDstBegin + 1;
                        continue;
                        }

                         if (XmlCharType.IsSurrogate(ch)) { pDst = EncodeSurrogate(pSrc, pSrcEnd, pDst); pSrc += 2; }
                    else if (ch <= 0x7F || ch >= 0xFFFE) { pDst = InvalidXmlChar(ch, pDst, false); pSrc++; }
                    else { pDst = EncodeMultibyteUTF8(ch, pDst); pSrc++; }
                    }

                bufPos = (Int32)(pDst - pDstBegin);
                }
            }
        #endregion
        #region M:WriteRawWithCharChecking(Char*,Char*)
        protected unsafe void WriteRawWithCharChecking(Char* pSrcBegin,Char* pSrcEnd) {
            fixed (Byte* pDstBegin = bufBytes)
                {
                var pSrc = pSrcBegin;
                var pDst = pDstBegin + bufPos;

                var ch = 0;
                for (;;) {
                    var pDstEnd = pDst + (pSrcEnd - pSrc);
                    if (pDstEnd > pDstBegin + bufLen)
                        {
                        pDstEnd = pDstBegin + bufLen;
                        }

                    while (pDst < pDstEnd && (((xmlCharType.charProperties[(ch = *pSrc)] & XmlCharType.fText) != 0) && ch <= 0x7F))
                        {
                        *pDst = (Byte)ch;
                        pDst++;
                        pSrc++;
                        }

                    Debug.Assert(pSrc <= pSrcEnd);

                    // end of value
                    if (pSrc >= pSrcEnd)
                        {
                        break;
                        }

                    // end of buffer
                    if (pDst >= pDstEnd)
                        {
                        bufPos = (Int32)(pDst - pDstBegin);
                        FlushBuffer();
                        pDst = pDstBegin + 1;
                        continue;
                        }

                    // handle special characters
                    switch (ch)
                        {
                        case ']':
                        case '<':
                        case '&':
                        case (Char)0x9:
                            *pDst = (Byte)ch;
                            pDst++;
                            break;
                        case (Char)0xD:
                            if (NewLineHandling == NewLineHandling.Replace)
                                {
                                // Normalize "\r\n", or "\r" to NewLineChars
                                if (pSrc[1] == '\n')
                                    {
                                    pSrc++;
                                    }

                                pDst = WriteNewLine(pDst);

                                }
                            else
                                {
                                *pDst = (Byte)ch;
                                pDst++;
                                }
                            break;
                        case (Char)0xA:
                            if (NewLineHandling == NewLineHandling.Replace)
                                {
                                pDst = WriteNewLine(pDst);
                                }
                            else
                                {
                                *pDst = (Byte)ch;
                                pDst++;
                                }
                            break;
                        default:
                                 if (XmlCharType.IsSurrogate(ch)) { pDst = EncodeSurrogate(pSrc, pSrcEnd, pDst); pSrc += 2; }
                            else if (ch <= 0x7F || ch >= 0xFFFE) { pDst = InvalidXmlChar(ch, pDst, false); pSrc++; }
                            else { pDst = EncodeMultibyteUTF8(ch, pDst); pSrc++; }
                            continue;
                        }
                    pSrc++;
                    }
                bufPos = (Int32)(pDst - pDstBegin);
                }
            }
        #endregion
        #region M:WriteCommentOrPi(String,Int32)
        protected unsafe void WriteCommentOrPi(String text,Int32 stopChar) {
            if (text.Length == 0) {
                if (bufPos >= bufLen)
                    {
                    FlushBuffer();
                    }
                return;
                }
            // write text
            fixed (Char* pSrcBegin = text)

            fixed (Byte* pDstBegin = bufBytes)
                {
                var pSrc = pSrcBegin;
                var pSrcEnd = pSrcBegin + text.Length;
                var pDst = pDstBegin + bufPos;
                var ch = 0;
                for (;;)
                    {
                    var pDstEnd = pDst + (pSrcEnd - pSrc);
                    if (pDstEnd > pDstBegin + bufLen)
                        {
                        pDstEnd = pDstBegin + bufLen;
                        }

                    while (pDst < pDstEnd && (((xmlCharType.charProperties[(ch = *pSrc)] & XmlCharType.fText) != 0) && ch != stopChar && ch <= 0x7F))
                        {
                        *pDst = (Byte)ch;
                        pDst++;
                        pSrc++;
                        }

                    Debug.Assert(pSrc <= pSrcEnd);

                    // end of value
                    if (pSrc >= pSrcEnd)
                        {
                        break;
                        }

                    // end of buffer
                    if (pDst >= pDstEnd)
                        {
                        bufPos = (Int32)(pDst - pDstBegin);
                        FlushBuffer();
                        pDst = pDstBegin + 1;
                        continue;
                        }

                    // handle special characters
                    switch (ch)
                        {
                        case '-':
                            *pDst = (Byte)'-';
                            pDst++;
                            if (ch == stopChar)
                                {
                                // Insert space between adjacent dashes or before comment's end dashes
                                if (pSrc + 1 == pSrcEnd || *(pSrc + 1) == '-')
                                    {
                                    *pDst = (Byte)' ';
                                    pDst++;
                                    }
                                }
                            break;
                        case '?':
                            *pDst = (Byte)'?';
                            pDst++;
                            if (ch == stopChar)
                                {
                                // Processing instruction: insert space between adjacent '?' and '>' 
                                if (pSrc + 1 < pSrcEnd && *(pSrc + 1) == '>')
                                    {
                                    *pDst = (Byte)' ';
                                    pDst++;
                                    }
                                }
                            break;
                        case ']':
                            *pDst = (Byte)']';
                            pDst++;
                            break;
                        case (Char)0xD:
                            if (NewLineHandling == NewLineHandling.Replace)
                                {
                                // Normalize "\r\n", or "\r" to NewLineChars
                                if (pSrc[1] == '\n')
                                    {
                                    pSrc++;
                                    }

                                pDst = WriteNewLine(pDst);
                                }
                            else
                                {
                                *pDst = (Byte)ch;
                                pDst++;
                                }
                            break;
                        case (Char)0xA:
                            if (NewLineHandling == NewLineHandling.Replace)
                                {
                                pDst = WriteNewLine(pDst);
                                }
                            else
                                {
                                *pDst = (Byte)ch;
                                pDst++;
                                }
                            break;
                        case '<':
                        case '&':
                        case (Char)0x9:
                            *pDst = (Byte)ch;
                            pDst++;
                            break;
                        default:
                                 if (XmlCharType.IsSurrogate(ch)) { pDst = EncodeSurrogate(pSrc, pSrcEnd, pDst); pSrc += 2; }
                            else if (ch <= 0x7F || ch >= 0xFFFE) { pDst = InvalidXmlChar(ch, pDst, false); pSrc++; }
                            else { pDst = EncodeMultibyteUTF8(ch, pDst); pSrc++; }
                            continue;
                        }
                    pSrc++;
                    }
                bufPos = (Int32)(pDst - pDstBegin);
                }
            }
        #endregion
        #region M:WriteCDataSection(String)
        protected unsafe void WriteCDataSection(String text) {
            if (text.Length == 0) {
                if (bufPos >= bufLen) {
                    FlushBuffer();
                    }
                return;
                }

            // write text

            fixed (Char* pSrcBegin = text)
            fixed (Byte* pDstBegin = bufBytes) {
                var pSrc = pSrcBegin;
                var pSrcEnd = pSrcBegin + text.Length;
                var target = pDstBegin + bufPos;

                var c = 0;
                for (;;) {
                    var pDstEnd = target + (pSrcEnd - pSrc);
                    if (pDstEnd > pDstBegin + bufLen)
                        {
                        pDstEnd = pDstBegin + bufLen;
                        }

                    while (target < pDstEnd &&
                        (((xmlCharType.charProperties[(c = *pSrc)] & XmlCharType.fAttrValue) != 0) && c != ']' && c <= 0x7F))
                        {
                        *target = (Byte)c;
                        target++;
                        pSrc++;
                        }

                    Debug.Assert(pSrc <= pSrcEnd);

                    // end of value
                    if (pSrc >= pSrcEnd)
                        {
                        break;
                        }

                    // end of buffer
                    if (target >= pDstEnd) {
                        bufPos = (Int32)(target - pDstBegin);
                        FlushBuffer();
                        target = pDstBegin + 1;
                        continue;
                        }

                    // handle special characters
                    switch (c) {
                        case '>':
                            if (hadDoubleBracket && target[-1] == (Byte)']') {
                                // pDst[-1] will always correct - there is a padding character at _BUFFER[0]
                                // The characters "]]>" were found within the CData text
                                target = RawEndCData(target);
                                target = RawStartCData(target);
                                }
                            *target = (Byte)'>';
                            target++;
                            break;
                        case ']':
                            if (target[-1] == (Byte)']')
                                {
                                // pDst[-1] will always correct - there is a padding character at _BUFFER[0]
                                hadDoubleBracket = true;
                                }
                            else
                                {
                                hadDoubleBracket = false;
                                }
                            *target = (Byte)']';
                            target++;
                            break;
                        case '\r':
                            if (NewLineHandling == NewLineHandling.Replace) {
                                // Normalize "\r\n", or "\r" to NewLineChars
                                if (pSrc[1] == '\n')
                                    {
                                    pSrc++;
                                    }

                                target = WriteNewLine(target);
                                }
                            else
                                {
                                *target = (Byte)c;
                                target++;
                                }
                            break;
                        case '\n':
                            if (NewLineHandling == NewLineHandling.Replace)
                                {
                                target = WriteNewLine(target);
                                }
                            else
                                {
                                *target = (Byte)c;
                                target++;
                                }
                            break;
                        case '&':
                        case '<':
                        case '"':
                        case '\'':
                        case '\t':
                            *target = (Byte)c;
                            target++;
                            break;
                        default:
                                 if (XmlCharType.IsSurrogate(c)) { target = EncodeSurrogate(pSrc, pSrcEnd, target); pSrc += 2; }
                            else if (c <= 0x7F || c >= 0xFFFE) { target = InvalidXmlChar(c, target, false); pSrc++; }
                            else { target = EncodeMultibyteUTF8(c, target); pSrc++; }
                            continue;
                        }
                    pSrc++;
                    }
                bufPos = (Int32)(target - pDstBegin);
                }
            }
        #endregion
        #region M:IsSurrogateByte(Byte):Boolean
        // Returns true if UTF8 encoded byte is first of four bytes that encode a surrogate pair.
        // To do this, detect the bit pattern 11110xxx.
        private static Boolean IsSurrogateByte(Byte b)
            {
            return (b & 0xF8) == 0xF0;
            }
        #endregion
        #region M:EncodeSurrogate(Char*,Char*,Byte*):Byte*
        private static unsafe Byte* EncodeSurrogate(Char* pSrc, Char* pSrcEnd, Byte* pDst)
            {
            Debug.Assert(XmlCharType.IsSurrogate(*pSrc));
            Int32 ch = *pSrc;
            if (ch <= XmlCharType.SurHighEnd)
                {
                if (pSrc + 1 < pSrcEnd)
                    {
                    Int32 lowChar = pSrc[1];
                    if (lowChar >= XmlCharType.SurLowStart &&
                        (DontThrowOnInvalidSurrogatePairs || lowChar <= XmlCharType.SurLowEnd))
                        {

                        // Calculate Unicode scalar value for easier manipulations (see section 3.7 in Unicode spec)
                        // The scalar value repositions surrogate values to start at 0x10000.

                        ch = XmlCharType.CombineSurrogateChar(lowChar, ch);

                        pDst[0] = (Byte)(0xF0 | (ch >> 18));
                        pDst[1] = (Byte)(0x80 | (ch >> 12) & 0x3F);
                        pDst[2] = (Byte)(0x80 | (ch >> 6) & 0x3F);
                        pDst[3] = (Byte)(0x80 | ch & 0x3F);
                        pDst += 4;

                        return pDst;
                        }
                    throw XmlExceptions.CreateInvalidSurrogatePairException((Char)lowChar, (Char)ch);
                    }
                throw new ArgumentException("The surrogate pair is invalid. Missing a low surrogate character.");
                }
            throw XmlExceptions.CreateInvalidHighSurrogateCharException((Char)ch);
            }
        #endregion
        #region M:InvalidXmlChar(Int32,Byte*,Boolean):Byte*
        private unsafe Byte* InvalidXmlChar(Int32 ch, Byte* pDst, Boolean entitize)
            {
            Debug.Assert(!xmlCharType.IsWhiteSpace((Char)ch));
            Debug.Assert(!xmlCharType.IsAttributeValueChar((Char)ch));

            if (CheckCharacters)
                {
                // This method will never be called on surrogates, so it is ok to pass in '\0' to the CreateInvalidCharException
                throw XmlExceptions.CreateInvalidCharException((Char)ch, '\0');
                }
            else
                {
                if (entitize)
                    {
                    return CharEntity(pDst, (Char)ch);
                    }
                else
                    {

                    if (ch < 0x80)
                        {

                        *pDst = (Byte)ch;
                        pDst++;

                        }
                    else
                        {
                        pDst = EncodeMultibyteUTF8(ch, pDst);
                        }

                    return pDst;
                    }
                }
            }
        #endregion
        #region M:EncodeChar({ref}Char*,Char*,{ref}Byte*)
        internal unsafe void EncodeChar(ref Char* pSrc,Char* pSrcEnd,ref Byte* pDst) {
            Int32 ch = *pSrc;
                 if (XmlCharType.IsSurrogate(ch)) { pDst = EncodeSurrogate(pSrc, pSrcEnd, pDst); pSrc += 2; }
            else if (ch <= 0x7F || ch >= 0xFFFE) { pDst = InvalidXmlChar(ch, pDst, false); pSrc++; }
            else { pDst = EncodeMultibyteUTF8(ch, pDst); pSrc++; }
            }
        #endregion
        #region M:EncodeMultibyteUTF8(Int32,Byte*):Byte*
        internal static unsafe Byte* EncodeMultibyteUTF8(Int32 ch, Byte* pDst)
            {
            Debug.Assert(ch >= 0x80 && !XmlCharType.IsSurrogate(ch));

            /* UTF8-2: If ch is in 0x80-0x7ff range, then use 2 bytes to encode it */
            if (ch < 0x800)
                {
                *pDst = (Byte)(unchecked((SByte)0xC0) | (ch >> 6));
                }
            /* UTF8-3: If ch is anything else, then default to using 3 bytes to encode it. */
            else
                {
                *pDst = (Byte)(unchecked((SByte)0xE0) | (ch >> 12));
                pDst++;

                *pDst = (Byte)(unchecked((SByte)0x80) | (ch >> 6) & 0x3F);
                }
            pDst++;
            *pDst = (Byte)(0x80 | ch & 0x3F);
            return pDst + 1;
            }
        #endregion
        #region M:CharToUTF8({ref}Char*,Char*,{ref}Byte*)
        // Encode *pSrc as a sequence of UTF8 bytes.  Write the bytes to pDst and return an updated pointer.
        internal static unsafe void CharToUTF8(ref Char* pSrc,Char* pSrcEnd,ref Byte* pDst) {
            Int32 ch = *pSrc;
            if (ch <= 0x7F)
                {
                *pDst = (Byte)ch;
                pDst++;
                pSrc++;
                }
            else if (XmlCharType.IsSurrogate(ch))
                {
                pDst = EncodeSurrogate(pSrc, pSrcEnd, pDst);
                pSrc += 2;
                }
            else
                {
                pDst = EncodeMultibyteUTF8(ch, pDst);
                pSrc++;
                }
            }
        #endregion
        #region M:WriteNewLine(Byte*):Byte*
        // Write NewLineChars to the specified buffer position and return an updated position.
        protected unsafe Byte* WriteNewLine(Byte* pDst) {
            fixed (Byte* pDstBegin = bufBytes) {
                bufPos = (Int32)(pDst - pDstBegin);
                // Let RawText do the real work
                RawText(NewLineChars);
                return pDstBegin + bufPos;
                }
            }
        #endregion

        // Following methods do not check whether pDst is beyond the bufSize because the buffer was allocated with a OVERFLOW to accomodate
        // for the writes of small constant-length string as below.

        #region M:LtEntity(Byte*):Byte*
        // Entitize '<' as "&lt;".  Return an updated pointer.
        protected static unsafe Byte* LtEntity(Byte* pDst)
            {
            pDst[0] = (Byte)'&';
            pDst[1] = (Byte)'l';
            pDst[2] = (Byte)'t';
            pDst[3] = (Byte)';';
            return pDst + 4;
            }
        #endregion
        #region M:GtEntity(Byte*):Byte*
        // Entitize '>' as "&gt;".  Return an updated pointer.
        protected static unsafe Byte* GtEntity(Byte* pDst)
            {
            pDst[0] = (Byte)'&';
            pDst[1] = (Byte)'g';
            pDst[2] = (Byte)'t';
            pDst[3] = (Byte)';';
            return pDst + 4;
            }
        #endregion
        #region M:AmpEntity(Byte*):Byte*
        // Entitize '&' as "&amp;".  Return an updated pointer.
        protected static unsafe Byte* AmpEntity(Byte* pDst)
            {
            pDst[0] = (Byte)'&';
            pDst[1] = (Byte)'a';
            pDst[2] = (Byte)'m';
            pDst[3] = (Byte)'p';
            pDst[4] = (Byte)';';
            return pDst + 5;
            }
        #endregion
        #region M:QuoteEntity(Byte*):Byte*
        // Entitize '"' as "&quot;".  Return an updated pointer.
        protected static unsafe Byte* QuoteEntity(Byte* pDst)
            {
            pDst[0] = (Byte)'&';
            pDst[1] = (Byte)'q';
            pDst[2] = (Byte)'u';
            pDst[3] = (Byte)'o';
            pDst[4] = (Byte)'t';
            pDst[5] = (Byte)';';
            return pDst + 6;
            }
        #endregion
        #region M:TabEntity(Byte*):Byte*
        // Entitize '\t' as "&#x9;".  Return an updated pointer.
        protected static unsafe Byte* TabEntity(Byte* pDst)
            {
            pDst[0] = (Byte)'&';
            pDst[1] = (Byte)'#';
            pDst[2] = (Byte)'x';
            pDst[3] = (Byte)'9';
            pDst[4] = (Byte)';';
            return pDst + 5;
            }
        #endregion
        #region M:LineFeedEntity(Byte*):Byte*
        // Entitize 0xa as "&#xA;".  Return an updated pointer.
        protected static unsafe Byte* LineFeedEntity(Byte* pDst)
            {
            pDst[0] = (Byte)'&';
            pDst[1] = (Byte)'#';
            pDst[2] = (Byte)'x';
            pDst[3] = (Byte)'A';
            pDst[4] = (Byte)';';
            return pDst + 5;
            }
        #endregion
        #region M:CarriageReturnEntity(Byte*):Byte*
        // Entitize 0xd as "&#xD;".  Return an updated pointer.
        protected static unsafe Byte* CarriageReturnEntity(Byte* pDst)
            {
            pDst[0] = (Byte)'&';
            pDst[1] = (Byte)'#';
            pDst[2] = (Byte)'x';
            pDst[3] = (Byte)'D';
            pDst[4] = (Byte)';';
            return pDst + 5;
            }
        #endregion
        #region M:CharEntity(Byte*,Char):Byte*
        private static unsafe Byte* CharEntity(Byte* pDst, Char ch)
            {
            var s = ((Int32)ch).ToString("X", NumberFormatInfo.InvariantInfo);
            pDst[0] = (Byte)'&';
            pDst[1] = (Byte)'#';
            pDst[2] = (Byte)'x';
            pDst += 3;

            fixed (Char* pSrc = s) {
                var pS = pSrc;
                while ((*pDst++ = (byte)*pS++) != 0)
                    {
                    }
                }

            pDst[-1] = (Byte)';';
            return pDst;
            }
        #endregion
        #region M:RawStartCData(Byte*):Byte*
        // Write "<![CDATA[" to the specified buffer.  Return an updated pointer.
        protected static unsafe Byte* RawStartCData(Byte* pDst)
            {
            pDst[0] = (Byte)'<';
            pDst[1] = (Byte)'!';
            pDst[2] = (Byte)'[';
            pDst[3] = (Byte)'C';
            pDst[4] = (Byte)'D';
            pDst[5] = (Byte)'A';
            pDst[6] = (Byte)'T';
            pDst[7] = (Byte)'A';
            pDst[8] = (Byte)'[';
            return pDst + 9;
            }
        #endregion
        #region M:RawEndCData(Byte*):Byte*
        // Write "]]>" to the specified buffer.  Return an updated pointer.
        protected static unsafe Byte* RawEndCData(Byte* pDst)
            {
            pDst[0] = (Byte)']';
            pDst[1] = (Byte)']';
            pDst[2] = (Byte)'>';
            return pDst + 3;
            }
        #endregion
        #region M:ValidateContentChars(String,String,Boolean)
        protected void ValidateContentChars(String chars,String propertyName,Boolean allowOnlyWhitespace) {
            if (allowOnlyWhitespace) {
                if (!xmlCharType.IsOnlyWhitespace(chars)) {
                    throw new ArgumentException($"XmlWriterSettings.{propertyName} can contain only valid XML white space characters when XmlWriterSettings.CheckCharacters and XmlWriterSettings.NewLineOnAttributes are true.");
                    }
                }
            else
                {
                String error = null;
                for (var i = 0; i < chars.Length; i++) {
                    if (!xmlCharType.IsTextChar(chars[i])) {
                        switch (chars[i])
                            {
                            case '\n':
                            case '\r':
                            case '\t':
                                continue;
                            case '<':
                            case '&':
                            case ']':
                                error = String.Format("'{0}', hexadecimal value {1}, is an invalid character.", XmlExceptions.BuildCharExceptionArgs(chars, i));
                                goto Error;
                            default:
                                if (XmlCharType.IsHighSurrogate(chars[i]))
                                    {
                                    if (i + 1 < chars.Length)
                                        {
                                        if (XmlCharType.IsLowSurrogate(chars[i + 1]))
                                            {
                                            i++;
                                            continue;
                                            }
                                        }
                                    error = "The surrogate pair is invalid. Missing a low surrogate character.";
                                    goto Error;
                                    }
                                else if (XmlCharType.IsLowSurrogate(chars[i]))
                                    {
                                    error = $"Invalid high surrogate character (0x{((UInt32)chars[i]).ToString("X", CultureInfo.InvariantCulture)}). A high surrogate character must have a value from range (0xD800 - 0xDBFF).";
                                    goto Error;
                                    }
                                continue;
                            }
                        }
                    }
                return;

            Error:
                throw new ArgumentException($"XmlWriterSettings.{propertyName} can contain only valid XML text content characters when XmlWriterSettings.CheckCharacters is true. {error}");
                }
            }
        #endregion
        }
    }