using System;
using System.Diagnostics;
using BinaryStudio.SqlServer.Infrastructure;
using BinaryStudio.SqlServer.Infrastructure.DAC;

namespace dacpac
    {
    internal class Program
        {
        private static void Main(String[] args) {
            //var maxN = 0;
            //foreach (SqlPermission i in Enum.GetValues(typeof(SqlPermission))) {
            //    maxN = Math.Max(maxN,i.ToString().Length);
            //    }
            //foreach (SqlPermission i in Enum.GetValues(typeof(SqlPermission))) {
            //    Debug.WriteLine(String.Format($"{{0,-{maxN}}} = 0x{{1:x4}},", i,(Int32)i));
            //    }
            var r = DataSchemaModel.LoadFrom("model.xml");
            return;
            }
        }
    }
