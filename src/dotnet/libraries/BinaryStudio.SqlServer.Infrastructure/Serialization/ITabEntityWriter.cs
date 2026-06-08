using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public interface ITabEntityWriter
        {
        unsafe char* Write(char* target);
        unsafe byte* Write(byte* target);
        }
    }
