using DocumentFormat.OpenXml.Bibliography;
using System;
using System.ComponentModel;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public interface ISqlXmlWriter
        {
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
        IDisposable ElementGroup(String prefix,String localName,String ns);
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
        IDisposable ElementGroup(String localName,String ns);
        #endregion
        #region M:ElementGroup(String):IDisposable
        /// <summary>Begins a new XML element with the specified local name and returns an IDisposable that closes the element when disposed.</summary>
        /// <param name="localName">The local name of the XML element to start. Cannot be null.</param>
        /// <returns>An IDisposable that, when disposed, closes the started XML element.</returns>
        /// <remarks>
        /// Use this method within a using statement to ensure the XML element is properly
        /// closed, even if an exception occurs.
        /// </remarks>
        IDisposable ElementGroup(String localName);
        #endregion
        #region M:WriteAttribute<T>(String,String,String,T)
        /// <summary>When overridden in a derived class, writes out the attribute with the specified prefix, local name, namespace URI, and value.</summary>
        /// <param name="prefix">The namespace prefix of the attribute.</param>
        /// <param name="localName">The local name of the attribute.</param>
        /// <param name="ns">The namespace URI of the attribute.</param>
        /// <param name="value">The value of the attribute.</param>
        /// <exception cref="T:System.InvalidOperationException">The state of writer is not <see langword="WriteState.Element"/> or writer is closed.</exception>
        /// <exception cref="T:System.ArgumentException">The <see langword="xml:space"/> or <see langword="xml:lang"/> attribute value is invalid.</exception>
        /// <exception cref="T:System.Xml.XmlException">The <paramref name="localName"/> or <paramref name="ns"/> is <see langword="null"/>.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:BinaryStudio.SqlServer.Infrastructure.ISqlXmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        void WriteAttribute<T>(String prefix,String localName,String ns,T value);
        #endregion
        #region M:WriteAttribute<T>(String,String,T)
        /// <summary>When overridden in a derived class, writes an attribute with the specified local name, namespace URI, and value.</summary>
        /// <param name="localName">The local name of the attribute.</param>
        /// <param name="ns">The namespace URI to associate with the attribute.</param>
        /// <param name="value">The value of the attribute.</param>
        /// <exception cref="T:System.InvalidOperationException">The state of writer is not <see langword="WriteState.Element"/> or writer is closed.</exception>
        /// <exception cref="T:System.ArgumentException">The <see langword="xml:space"/> or <see langword="xml:lang"/> attribute value is invalid.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:BinaryStudio.SqlServer.Infrastructure.ISqlXmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        void WriteAttribute<T>(String localName,String ns,T value);
        #endregion
        #region M:WriteAttribute<T>(String,T)
        /// <summary>When overridden in a derived class, writes out the attribute with the specified local name and value.</summary>
        /// <param name="localName">The local name of the attribute.</param>
        /// <param name="value">The value of the attribute.</param>
        /// <exception cref="T:System.InvalidOperationException">The state of writer is not <see langword="WriteState.Element"/> or writer is closed.</exception>
        /// <exception cref="T:System.ArgumentException">The <see langword="xml:space"/> or <see langword="xml:lang"/> attribute value is invalid.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:BinaryStudio.SqlServer.Infrastructure.ISqlXmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        void WriteAttribute<T>(String localName,T value);
        #endregion
        #region M:WriteAttribute<T>(String,T,TypeConverter)
        /// <summary>Writes out the attribute with the specified local name and value using specified converter.</summary>
        /// <param name="localName">The local name of the attribute.</param>
        /// <param name="value">The value of the attribute.</param>
        /// <param name="converter">The value converter.</param>
        /// <exception cref="T:System.InvalidOperationException">The state of writer is not <see langword="WriteState.Element"/> or writer is closed.</exception>
        /// <exception cref="T:System.ArgumentException">The <see langword="xml:space"/> or <see langword="xml:lang"/> attribute value is invalid.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:BinaryStudio.SqlServer.Infrastructure.ISqlXmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        void WriteAttribute<T>(String localName,T value,TypeConverter converter);
        #endregion
        #region M:WriteCData(String,String,String,String)
        /// <summary>Writes an element with the specified prefix, local name, namespace URI, and CDATA block.</summary>
        /// <param name="prefix">The prefix of the element.</param>
        /// <param name="localName">The local name of the element.</param>
        /// <param name="ns">The namespace URI of the element.</param>
        /// <param name="text">The text to place inside the CDATA block.</param>
        /// <exception cref="T:System.ArgumentException">The <paramref name="localName"/> value is <see langword="null"/> or an empty string.-or-The parameter values are not valid.</exception>
        /// <exception cref="T:System.Text.EncoderFallbackException">There is a character in the buffer that is a valid XML character but is not valid for the output encoding. For example, if the output encoding is ASCII, you should only use characters from the range of 0 to 127 for element and attribute names. The invalid character might be in the argument of this method or in an argument of previous methods that were writing to the buffer. Such characters are escaped by character entity references when possible (for example, in text nodes or attribute values). However, the character entity reference is not allowed in element and attribute names, comments, processing instructions, or CDATA sections.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:BinaryStudio.SqlServer.Infrastructure.ISqlXmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        void WriteCData(String prefix,String localName,String ns,String text);
        #endregion
        #region M:WriteCData(String,String,String)
        /// <summary>Writes an element with the specified local name, namespace URI, and CDATA block.</summary>
        /// <param name="localName">The local name of the element.</param>
        /// <param name="ns">The namespace URI to associate with the element.</param>
        /// <param name="text">The text to place inside the CDATA block.</param>
        /// <exception cref="T:System.ArgumentException">The <paramref name="localName"/> value is <see langword="null"/> or an empty string.-or-The parameter values are not valid.</exception>
        /// <exception cref="T:System.Text.EncoderFallbackException">There is a character in the buffer that is a valid XML character but is not valid for the output encoding. For example, if the output encoding is ASCII, you should only use characters from the range of 0 to 127 for element and attribute names. The invalid character might be in the argument of this method or in an argument of previous methods that were writing to the buffer. Such characters are escaped by character entity references when possible (for example, in text nodes or attribute values). However, the character entity reference is not allowed in element and attribute names, comments, processing instructions, or CDATA sections.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:BinaryStudio.SqlServer.Infrastructure.ISqlXmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        void WriteCData(String localName,String ns,String text);
        #endregion
        #region M:WriteCData(String,String)
        /// <summary>Writes an element with the specified local name and CDATA block.</summary>
        /// <param name="localName">The local name of the element.</param>
        /// <param name="text">The text to place inside the CDATA block.</param>
        /// <exception cref="T:System.ArgumentException">The <paramref name="localName"/> value is <see langword="null"/> or an empty string.-or-The parameter values are not valid.</exception>
        /// <exception cref="T:System.Text.EncoderFallbackException">There is a character in the buffer that is a valid XML character but is not valid for the output encoding. For example, if the output encoding is ASCII, you should only use characters from the range of 0 to 127 for element and attribute names. The invalid character might be in the argument of this method or in an argument of previous methods that were writing to the buffer. Such characters are escaped by character entity references when possible (for example, in text nodes or attribute values). However, the character entity reference is not allowed in element and attribute names, comments, processing instructions, or CDATA sections.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:BinaryStudio.SqlServer.Infrastructure.ISqlXmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        void WriteCData(String localName,String text);
        #endregion
        #region M:WriteBase64(String,String,String,Byte[])
        /// <summary>Writes an element with the specified prefix, local name, namespace URI, and BASE64 block.</summary>
        /// <param name="prefix">The prefix of the element.</param>
        /// <param name="localName">The local name of the element.</param>
        /// <param name="ns">The namespace URI of the element.</param>
        /// <param name="buffer">Byte array to encode.</param>
        /// <exception cref="T:System.ArgumentException">The <paramref name="localName"/> value is <see langword="null"/> or an empty string.-or-The parameter values are not valid.</exception>
        /// <exception cref="T:System.Text.EncoderFallbackException">There is a character in the buffer that is a valid XML character but is not valid for the output encoding. For example, if the output encoding is ASCII, you should only use characters from the range of 0 to 127 for element and attribute names. The invalid character might be in the argument of this method or in an argument of previous methods that were writing to the buffer. Such characters are escaped by character entity references when possible (for example, in text nodes or attribute values). However, the character entity reference is not allowed in element and attribute names, comments, processing instructions, or CDATA sections.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:BinaryStudio.SqlServer.Infrastructure.ISqlXmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        void WriteBase64(String prefix,String localName,String ns,Byte[] buffer);
        #endregion
        #region M:WriteBase64(String,String,Byte[])
        /// <summary>Writes an element with the specified local name, namespace URI, and BASE64 block.</summary>
        /// <param name="localName">The local name of the element.</param>
        /// <param name="ns">The namespace URI of the element.</param>
        /// <param name="buffer">Byte array to encode.</param>
        /// <exception cref="T:System.ArgumentException">The <paramref name="localName"/> value is <see langword="null"/> or an empty string.-or-The parameter values are not valid.</exception>
        /// <exception cref="T:System.Text.EncoderFallbackException">There is a character in the buffer that is a valid XML character but is not valid for the output encoding. For example, if the output encoding is ASCII, you should only use characters from the range of 0 to 127 for element and attribute names. The invalid character might be in the argument of this method or in an argument of previous methods that were writing to the buffer. Such characters are escaped by character entity references when possible (for example, in text nodes or attribute values). However, the character entity reference is not allowed in element and attribute names, comments, processing instructions, or CDATA sections.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:BinaryStudio.SqlServer.Infrastructure.ISqlXmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        void WriteBase64(String localName,String ns,Byte[] buffer);
        #endregion
        #region M:WriteBase64(String,Byte[])
        /// <summary>Writes an element with the specified local name and BASE64 block.</summary>
        /// <param name="localName">The local name of the element.</param>
        /// <param name="buffer">Byte array to encode.</param>
        /// <exception cref="T:System.ArgumentException">The <paramref name="localName"/> value is <see langword="null"/> or an empty string.-or-The parameter values are not valid.</exception>
        /// <exception cref="T:System.Text.EncoderFallbackException">There is a character in the buffer that is a valid XML character but is not valid for the output encoding. For example, if the output encoding is ASCII, you should only use characters from the range of 0 to 127 for element and attribute names. The invalid character might be in the argument of this method or in an argument of previous methods that were writing to the buffer. Such characters are escaped by character entity references when possible (for example, in text nodes or attribute values). However, the character entity reference is not allowed in element and attribute names, comments, processing instructions, or CDATA sections.</exception>
        /// <exception cref="T:System.InvalidOperationException">An <see cref="T:BinaryStudio.SqlServer.Infrastructure.ISqlXmlWriter"/> method was called before a previous asynchronous operation finished. In this case, <see cref="T:System.InvalidOperationException"/> is thrown with the message “An asynchronous operation is already in progress.”</exception>
        void WriteBase64(String localName,Byte[] buffer);
        #endregion
        ISqlXmlWriter ScheduleNewLineForNextAttribute();
        ISqlXmlWriter StopScheduleNewLineForNextAttribute();
        }
    }