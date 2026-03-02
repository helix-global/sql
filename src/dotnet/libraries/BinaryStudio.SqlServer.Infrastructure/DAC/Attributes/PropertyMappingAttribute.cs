using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    internal class DataSchemaModelPropertyMappingAttribute : Attribute,ISqlModelMappingAttribute
        {
        public String SourceName { get; }
        }
    }
