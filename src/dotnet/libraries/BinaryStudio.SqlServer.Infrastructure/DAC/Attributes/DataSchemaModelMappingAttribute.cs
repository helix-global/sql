using System;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [AttributeUsage(AttributeTargets.Class,AllowMultiple = true)]
    internal class DataSchemaModelMappingAttribute : Attribute
        {
        public String Type { get; }
        public DataSchemaModelMappingAttribute(String Type)
            {
            this.Type = Type;
            }
        }
    }
