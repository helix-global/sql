using System;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("Parameter")]
    internal class FastReportParameter : FastReportObject
        {
        [UsedImplicitly][Field] public String Name { get; }
        [UsedImplicitly][Field] public String DataType { get; }
        [UsedImplicitly][Field] public String Description { get; }
        [UsedImplicitly][Field] public String Expression { get; }
        [UsedImplicitly][Field] public String Value { get; }
        }
    }
