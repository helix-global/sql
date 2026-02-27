using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public static class Exceptions
        {
        public static String Format(Exception e) {
            if (e == null) { throw new ArgumentNullException(nameof(e)); }
            return new ExceptionFormat().ToString(e);
            }
        }
    }
