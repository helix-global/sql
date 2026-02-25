using System;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    [AttributeUsage(AttributeTargets.Class,AllowMultiple = true)]
    internal class DataSchemaModelSupportedRelationshipAttribute : Attribute
        {
        public String Relationship { get;set; }
        public DataSchemaModelSupportedRelationshipAttribute(String Relationship)
            {
            this.Relationship = Relationship;
            }
        }
    }
