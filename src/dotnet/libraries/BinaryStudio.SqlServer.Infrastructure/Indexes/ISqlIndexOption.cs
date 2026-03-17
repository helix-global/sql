using System;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public interface ISqlIndexOption
        {
        SqlIndexOptionType Type { get; }
        String FormatInline(ISqlObjectFormatter<ISqlIndexOption> formatter);
        }
    }