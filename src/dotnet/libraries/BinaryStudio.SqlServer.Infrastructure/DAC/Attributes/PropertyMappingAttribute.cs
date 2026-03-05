using System;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    internal class PropertyMappingAttribute : Attribute,ISqlModelMappingAttribute
        {
        public String Source { get; }
        }
    }
