using System;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    internal class PropertyMappingAttribute : Attribute,ISqlModelMappingAttribute
        {
        public String Source { get;set; }
        }
   }