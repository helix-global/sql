using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure
    {
    public class FastReport : SqlObject
        {
        #region M:LoadFrom(Byte[]):FastReport
        public static FastReport LoadFrom(Byte[] source)
            {
            if (source == null) { throw new ArgumentNullException(nameof(source)); }
            return null;
            }
        #endregion
        }
    }
