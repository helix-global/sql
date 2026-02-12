using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    internal class DataSchemaModelAttributeMappingAttribute : Attribute,IDataSchemaModelMappingAttribute
        {
        public String SourceName { get; }
        }
    }
