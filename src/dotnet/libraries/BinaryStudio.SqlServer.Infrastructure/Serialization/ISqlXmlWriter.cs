using System;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public interface ISqlXmlWriter
        {
        void WriteAttribute(Boolean newline,String localName,Object value);
        }
    }