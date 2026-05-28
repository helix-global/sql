using System;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("CommandParameter")]
    public class CommandParameter : Base
        {
        [UsedImplicitly][Field] public Int32 DataType { get; }
        [UsedImplicitly][Field] public Int32 Size { get; }
        [UsedImplicitly][Field] public String DefaultValue { get; }
        [UsedImplicitly][Field] public String Expression { get; }
        }
    }
