using System;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("Parameter")]
    internal class FastReportParameter : Base
        {
        [UsedImplicitly][Field(Order=1000201)] public String DataType { get; }
        [UsedImplicitly][Field(Order=1000203)] public String Description { get; }
        [UsedImplicitly][Field(Order=1000202)] public String Expression { get; }
        }
    }
