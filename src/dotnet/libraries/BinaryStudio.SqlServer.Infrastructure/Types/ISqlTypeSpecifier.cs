using System;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public interface ISqlTypeSpecifier
        {
        SqlDataType Type { get; }
        Int32? Precision { get; }
        Int32? Scale { get; }
        Int32? Length { get; }
        Boolean IsMaximum { get; }
        String ToString(ISqlObjectFormatter<ISqlTypeSpecifier> Formatter);
        }
    }