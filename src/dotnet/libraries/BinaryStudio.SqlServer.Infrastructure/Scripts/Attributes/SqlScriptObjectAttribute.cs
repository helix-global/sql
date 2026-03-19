using System;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [AttributeUsage(AttributeTargets.Class,AllowMultiple = true,Inherited = false)]
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
