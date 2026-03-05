using System;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class SqlModelFieldMappingAttribute : Attribute,ISqlModelMappingAttribute
        {
        public String Source { get;set; }
        public Boolean EmptyIfNull { get;set; }
        }
    }
