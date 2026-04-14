using System;
using System.Diagnostics;
using System.IO;
using System.Xml;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class XmlUtf8RawTextWriterIndent : XmlUtf8RawTextWriter
        {
        #region P:NewLineOnAttributes:Boolean
        protected internal override Boolean NewLineOnAttributes {
            get
                {
                if (_newLineOnAttributesA) { return true; }
                return _newLineOnAttributesB;
                }
            set
                {
                if (!_newLineOnAttributesA) {
                    _newLineOnAttributesB = value;
                    }
                }
            }
        #endregion

        protected Int32 indentLevel;
        protected String indentChars;

        protected Boolean mixedContent;
        private BitStack mixedContentStack;

        protected ConformanceLevel conformanceLevel = ConformanceLevel.Auto;

        #region ctor{Stream,XmlWriterSettings}
        public XmlUtf8RawTextWriterIndent(Stream stream,XmlWriterSettings settings)
            : base(stream, settings)
            {
            Init(settings);
            }
        #endregion

        #region P:Settings:XmlWriterSettings
        public override XmlWriterSettings Settings { get {
            var settings = base.Settings;
            settings.ReadOnly(false);
            settings.Indent = true;
            settings.IndentChars = indentChars;
            settings.NewLineOnAttributes = _newLineOnAttributesA;
            settings.ReadOnly(true);
            return settings;
            }}
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
            // Add indentation
            if (!mixedContent && base.textPos != base.bufPos)
                {
                WriteIndent();
                }
            base.WriteDocType(name, pubid, sysid, subset);
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
            Debug.Assert(!String.IsNullOrEmpty(localName) && prefix != null && ns != null);

            // Add indentation
            if (!mixedContent && base.textPos != base.bufPos) {
                WriteIndent();
                }
            indentLevel++;
            mixedContentStack.PushBit(mixedContent);
            base.WriteStartElement(prefix, localName, ns);
            }
        #endregion
        #region M:WriteEndElement(String,String,String)
        /// <summary>Serialize an element end tag: "&lt;/prefix:localName&gt;", if content was output.  Otherwise, serialize the shortcut syntax: " /&gt;".</summary>
        /// <param name="prefix">The namespace prefix of the element.</param>
        /// <param name="localName">The local name of the element.</param>
        /// <param name="ns">The namespace URI to associate with the element.</param>
        /// <remarks>This method should always be called instead of WriteEndElement() without parameters.</remarks>
        internal override void WriteEndElement(String prefix, String localName, String ns)
            {
            // Add indentation
            indentLevel--;
            if (!mixedContent && base.contentPos != base.bufPos)
                {
                // There was content, so try to indent
                if (base.textPos != base.bufPos)
                    {
                    WriteIndent();
                    }
                }
            mixedContent = mixedContentStack.PopBit();

            base.WriteEndElement(prefix, localName, ns);
            }
        #endregion
        #region M:WriteFullEndElement(String,String,String)
        /// <summary>Serialize a full element end tag: "&lt;/prefix:localName&gt;"</summary>
        /// <param name="prefix">The namespace prefix of the element.</param>
        /// <param name="localName">The local name of the element.</param>
        /// <param name="ns">The namespace URI to associate with the element.</param>
        /// <remarks>This method should always be called instead of WriteFullEndElement() without parameters.</remarks>
        internal override void WriteFullEndElement(String prefix, String localName, String ns)
            {
            // Add indentation
            indentLevel--;
            if (!mixedContent && base.contentPos != base.bufPos)
                {
                // There was content, so try to indent
                if (base.textPos != base.bufPos)
                    {
                    WriteIndent();
                    }
                }
            mixedContent = mixedContentStack.PopBit();

            base.WriteFullEndElement(prefix, localName, ns);
            }
        #endregion
        #region M:WriteStartAttribute(String,String,String)
        // Same as base class, plus possible indentation.
        /// <summary>Writes the start of an attribute with the specified prefix, local name, and namespace URI.</summary>
        /// <param name="prefix">The namespace prefix of the attribute.</param>
        /// <param name="localName">The local name of the attribute.</param>
        /// <param name="ns">The namespace URI for the attribute.</param>
        /// <exception cref="T:System.Text.EncoderFallbackException">There is a character in the buffer that is a valid XML character but is not valid for the output encoding. For example, if the output encoding is ASCII, you should only use characters from the range of 0 to 127 for element and attribute names. The invalid character might be in the argument of this method or in an argument of previous methods that were writing to the buffer. Such characters are escaped by character entity references when possible (for example, in text nodes or attribute values). However, the character entity reference is not allowed in element and attribute names, comments, processing instructions, or CDATA sections.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter" /> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        /// <remarks>Serialize an attribute tag using double quotes around the attribute value: 'prefix:localName="'</remarks>
        public override void WriteStartAttribute(String prefix,String localName,String ns) {
            // Add indentation
            if (NewLineOnAttributes) {
                WriteIndent();
                var nameScope = elementScopeStack.Peek();
                WriteWhitespace(new String(' ',nameScope.LocalName.Length));
                }
            base.WriteStartAttribute(prefix, localName, ns);
            }
        #endregion
        #region M:WriteCData(String)
        /// <summary>Writes out a &lt;![CDATA[...]]&gt; block containing the specified text.</summary>
        /// <param name="text">The text to place inside the CDATA block.</param>
        /// <exception cref="T:System.ArgumentException">The text would result in a non-well formed XML document.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        /// <remarks>Serialize a CData section. If the "]]&gt;" pattern is found within the text, replace it with "]]&gt;&lt;![CDATA[&gt;".</remarks>
        public override void WriteCData(String text) {
            mixedContent = true;
            WriteIndent();
            try
                {
                indentLevel++;
                base.WriteCData(text);
                }
            finally
                {
                indentLevel--;
                }
            WriteIndent(indentLevel-1);
            }
        #endregion
        #region M:WriteComment(String)
        /// <summary>Writes out a comment &lt;!--...--&gt; containing the specified text.</summary>
        /// <param name="text">Text to place inside the comment.</param>
        /// <exception cref="T:System.ArgumentException">The text would result in a non-well-formed XML document.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteComment(String text) {
            if (!mixedContent && base.textPos != base.bufPos) {
                WriteIndent();
                }
            base.WriteComment(text);
            }
        #endregion
        #region M:WriteProcessingInstruction(String,String)
        /// <summary>When overridden in a derived class, writes out a processing instruction with a space between the name and text as follows: &lt;?name text?&gt;.</summary>
        /// <param name="name">The name of the processing instruction.</param>
        /// <param name="text">The text to include in the processing instruction.</param>
        /// <exception cref="T:System.ArgumentException">The text would result in a non-well formed XML document. <paramref name="name"/> is either <see langword="null"/> or <see langword="String.Empty"/>.This method is being used to create an XML declaration after <see cref="M:System.Xml.XmlWriter.WriteStartDocument"/> has already been called.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteProcessingInstruction(String name,String text) {
            if (!mixedContent && base.textPos != base.bufPos) {
                WriteIndent();
                }
            base.WriteProcessingInstruction(name,text);
            }
        #endregion
        #region M:WriteEntityRef(String)
        /// <summary>Writes out an entity reference as <see langword="&amp;name;" />.</summary>
        /// <param name="name">The name of the entity reference.</param>
        /// <exception cref="T:System.ArgumentException"><paramref name="name"/> is either <see langword="null"/> or <see langword="String.Empty"/>.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteEntityRef(String name) {
            mixedContent = true;
            base.WriteEntityRef(name);
            }
        #endregion
        #region M:WriteCharEntity(Char)
        /// <summary>Forces the generation of a character entity for the specified Unicode character value.</summary>
        /// <param name="ch">The Unicode character for which to generate a character entity.</param>
        /// <exception cref="T:System.ArgumentException">The character is in the surrogate pair character range, <see langword="0xd800"/> - <see langword="0xdfff"/>.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteCharEntity(Char ch)
            {
            mixedContent = true;
            base.WriteCharEntity(ch);
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
            mixedContent = true;
            base.WriteSurrogateCharEntity(lowChar, highChar);
            }
        #endregion
        #region M:WriteWhitespace(String)
        /// <summary>Writes out the given white space.</summary>
        /// <param name="ws">The string of white space characters.</param>
        /// <exception cref="T:System.ArgumentException">The string contains non-white space characters.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteWhitespace(String ws)
            {
            mixedContent = true;
            base.WriteWhitespace(ws);
            }
        #endregion
        #region M:WriteString(String)
        /// <summary>Writes the given text content.</summary>
        /// <param name="text">The text to write.</param>
        /// <exception cref="T:System.ArgumentException">The text string contains an invalid surrogate pair.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        /// <remarks>Serialize either attribute or element text using XML rules.</remarks>
        public override void WriteString(String text)
            {
            mixedContent = true;
            base.WriteString(text);
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
        public override void WriteChars(Char[] buffer,Int32 index,Int32 count)
            {
            mixedContent = true;
            base.WriteChars(buffer,index,count);
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
        public override void WriteRaw(Char[] buffer,Int32 index,Int32 count)
            {
            mixedContent = true;
            base.WriteRaw(buffer,index,count);
            }
        #endregion
        #region M:WriteRaw(String)
        /// <summary>Writes raw markup manually from a string.</summary>
        /// <param name="data">String containing the text to write.</param>
        /// <exception cref="T:System.ArgumentException"><paramref name="data"/> is either <see langword="null"/> or <see langword="String.Empty"/>.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:System.Xml.XmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        public override void WriteRaw(String data)
            {
            mixedContent = true;
            base.WriteRaw(data);
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
            mixedContent = true;
            var values = Convert.ToBase64String(buffer,index,count,Base64FormattingOptions.InsertLineBreaks).Split(new String[] {"\n","\r\n" },StringSplitOptions.RemoveEmptyEntries);
            if (values.Length == 0) { return; }
            if (values.Length == 1) { WriteRaw(values[1].Trim()); }
            else
                {
                for (var i = 0; i < values.Length; i++) {
                    WriteIndent();
                    WriteRaw(values[i].Trim());
                    }
                WriteIndent(indentLevel-1);
                }
            }
        #endregion
        #region M:StartElementContent
        /// <summary>
        /// Serialize the end of an element start tag in preparation for content serialization: ">"
        /// </summary>
        internal override void StartElementContent()
            {
            // If this is the root element and we're writing a document
            //   do not inherit the mixedContent flag into the root element.
            //   This is to allow for whitespace nodes on root level
            //   without disabling indentation for the whole document.
            if (indentLevel == 1 && conformanceLevel == ConformanceLevel.Document)
                {
                mixedContent = false;
                }
            else
                {
                mixedContent = mixedContentStack.PeekBit();
                }
            base.StartElementContent();
            }
        #endregion
        #region M:OnRootElement(ConformanceLevel)
        /// <summary>Called before a root element is written (before the WriteStartElement call).</summary>
        /// <param name="currentConformanceLevel">Specifies the current conformance level the writer is operating with.</param>
        internal override void OnRootElement(ConformanceLevel currentConformanceLevel)
            {
            // Just remember the current conformance level
            conformanceLevel = currentConformanceLevel;
            }
        #endregion

        #region M:Init(XmlWriterSettings)
        private void Init(XmlWriterSettings settings)
            {
            indentLevel = 0;
            indentChars = settings.IndentChars;
            _newLineOnAttributesA = settings.NewLineOnAttributes;
            mixedContentStack = new BitStack();

            // check indent characters that they are valid XML characters
            if (CheckCharacters) {
                if (NewLineOnAttributes)
                    {
                    ValidateContentChars(indentChars, "IndentChars", true);
                    ValidateContentChars(NewLineChars, "NewLineChars", true);
                    }
                else
                    {
                    ValidateContentChars(indentChars, "IndentChars", false);
                    if (NewLineHandling != NewLineHandling.Replace)
                        {
                        ValidateContentChars(NewLineChars, "NewLineChars", false);
                        }
                    }
                }
            }
        #endregion
        #region M:WriteIndent
        /// <summary>
        /// Writes the current indentation to the output based on the configured indentation level.
        /// </summary>
        private void WriteIndent() {
            WriteIndent(indentLevel);
            }
        #endregion
        #region M:WriteIndent(Int32)
        /// <summary>Writes a newline followed by the specified indentation <paramref name="level"/> to the output.</summary>
        /// <param name="level">The number of indentation levels to write. Must be zero or greater.</param>
        private void WriteIndent(Int32 level) {
            RawText(NewLineChars);
            WriteIndentChars(level);
            }
        #endregion
        #region M:WriteIndentChars(Int32)
        /// <summary>Writes the indentation characters the specified number of times to the output.</summary>
        /// <param name="level">The number of indentation levels to write. Must be zero or greater.</param>
        private void WriteIndentChars(Int32 level) {
            for (var i = level; i > 0; i--)
                {
                RawText(indentChars);
                }
            }
        #endregion
        #region M:WriteNewLine(Byte*):Byte*
        /// <summary>Writes the configured new line character sequence to the output buffer at the specified destination pointer.</summary>
        /// <param name="target">A pointer to the current position in the output buffer where the new line sequence should be written.</param>
        /// <returns>A pointer to the position in the output buffer immediately after the written new line sequence.</returns>
        protected override unsafe Byte* WriteNewLine(Byte* target) {
            fixed (Byte* r = bufBytes) {
                bufPos = (Int32)(target - r);
                RawText(NewLineChars);
                if (InCDataSection) {
                    WriteIndentChars(indentLevel);
                    }
                return r + bufPos;
                }
            }
        #endregion
        #region M:WriteCDataSection(String)
        /// <summary>Writes a CDATA section containing the specified text to the output.</summary>
        /// <param name="text">The text to include within the CDATA section. May be an empty string to write an empty CDATA section.</param>
        protected override unsafe void WriteCDataSection(String text) {
            if (text.Length == 0) {
                if (bufPos >= bufLen) {
                    FlushBuffer();
                    }
                return;
                }
            WriteIndent();
            base.WriteCDataSection(text);
            WriteIndent(indentLevel);
            }
        #endregion

        private Boolean _newLineOnAttributesA;
        private Boolean _newLineOnAttributesB;
        }
    }