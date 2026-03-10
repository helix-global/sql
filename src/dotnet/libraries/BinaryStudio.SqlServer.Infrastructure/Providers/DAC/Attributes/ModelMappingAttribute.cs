using System;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [AttributeUsage(AttributeTargets.Class,AllowMultiple = true)]
    internal class ModelMappingAttribute : Attribute
        {
        public String Type { get; }
        public ModelMappingAttribute(String Type)
            {
            this.Type = Type;
            }
        }
    }
