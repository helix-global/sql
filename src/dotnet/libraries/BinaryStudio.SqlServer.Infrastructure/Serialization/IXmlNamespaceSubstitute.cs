using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public interface IXmlNamespaceSubstitute
        {
        String SubstituteNamespace(String ns);
        }
    }
