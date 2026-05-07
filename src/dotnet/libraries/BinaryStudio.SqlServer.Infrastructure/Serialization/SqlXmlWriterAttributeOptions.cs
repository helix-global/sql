using System;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [Flags]
    public enum SqlXmlWriterAttributeOptions
        {
        None = 0,
        ForceNewLine    = 0x0001,
        IgnoreDefault   = 0x0002
        }
    }