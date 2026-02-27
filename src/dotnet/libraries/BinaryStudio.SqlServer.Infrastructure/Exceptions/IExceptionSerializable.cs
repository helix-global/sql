using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal interface IExceptionSerializable
        {
        void WriteTo(IJsonWriter writer);
        }
    }
