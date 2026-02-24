using System;
using BinaryStudio.SqlServer.Infrastructure.DAC;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class SqlModelFieldMappingAttribute : Attribute,ISqlModelMappingAttribute
        {
        public String SourceName { get; }
        }
    }
