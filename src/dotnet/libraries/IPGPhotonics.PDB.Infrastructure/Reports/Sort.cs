using System;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;

    [FastReportClass("Sort")]
    internal sealed class Sort : FastReportObject
        {
        protected internal override String ClassName { get { return "Sort"; }}
        [UsedImplicitly][Field(Order=1000102)] public Boolean Descending { get; }
        [UsedImplicitly][Field(Order=1000101)] public String Expression { get; }
        }
    }