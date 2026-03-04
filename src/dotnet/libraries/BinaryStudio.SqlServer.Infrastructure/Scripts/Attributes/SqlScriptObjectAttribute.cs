using System;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class SqlScriptObjectAttribute : Attribute
        {
        public Type Type { get; }
        public SqlScriptObjectAttribute(Type type)
            {
            Type = type;
            }
        }
    }
