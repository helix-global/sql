using System;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal interface IJsonWriter
        {
        IDisposable ObjectGroup();
        IDisposable Array();
        IDisposable Constructor(String name);
        void WriteValue(String name, Object value);
        void WriteValue(Object value);
        void WriteValueIfNotNull(String name, Object value);
        void WritePropertyName(String name);
        void WriteComment(String comment);
        void WriteWhitespace(String whitespace);
        void WriteWhitespace(Int32 whitespace);
        void WriteRawString(String value);
        void WriteIndent();
        void WriteNull();
        }
    }
