using System;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("Column")]
    public class Column : DataComponentBase
        {
        [UsedImplicitly][Field] public String DataType { get; }
        [UsedImplicitly][Field] public String BindableControl { get; }
        }
    }