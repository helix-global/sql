using System;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class SqlModelFieldMappingAttribute : Attribute,ISqlModelMappingAttribute
        {
        public String SourceName { get;set; }
        }
    }
