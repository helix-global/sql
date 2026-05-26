using System;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [AttributeUsage(AttributeTargets.Class,AllowMultiple = true)]
    internal class FastReportClassAttribute : Attribute
        {
        public String Name { get; }
        public FastReportClassAttribute(String name) {
            Name = name;
            }
        }
    }
