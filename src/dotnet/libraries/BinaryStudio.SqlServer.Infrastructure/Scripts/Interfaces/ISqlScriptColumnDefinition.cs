using System;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal interface ISqlScriptColumnDefinition
        {
        SqlIdentifier Name { get; }
        Boolean IsComputed { get; }
        }
    }
