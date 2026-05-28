using System;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("Column")]
    internal class Column : DataComponentBase
        {
        [UsedImplicitly][Field] public Boolean Calculated { get; }
        [UsedImplicitly][Field] public String DataType { get; }
        [UsedImplicitly][Field] public String BindableControl { get; }
        [UsedImplicitly][Field] public String Expression { get; }
        [UsedImplicitly][Field] public String PropName { get; }
        [UsedImplicitly][Field] public ColumnFormat Format { get; }
        }
    }