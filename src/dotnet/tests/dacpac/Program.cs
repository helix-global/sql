using System;
using BinaryStudio.SqlServer.Infrastructure.DAC;

namespace dacpac
    {
    internal class Program
        {
        private static void Main(String[] args)
            {
            var r = DataSchemaModel.LoadFrom("model.xml");
            return;
            }
        }
    }
