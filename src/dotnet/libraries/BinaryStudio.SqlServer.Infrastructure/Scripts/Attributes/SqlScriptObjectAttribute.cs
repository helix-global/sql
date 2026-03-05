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

        public String TypeName { get; }
        public SqlScriptObjectAttribute(String typename)
            {
            TypeName = typename;
            }
        }
    }
