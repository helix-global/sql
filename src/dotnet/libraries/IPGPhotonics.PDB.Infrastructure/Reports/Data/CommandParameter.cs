using System;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("CommandParameter")]
    internal sealed class CommandParameter : Base
        {
        [UsedImplicitly][Field(Order=1000210)] public Int32 DataType { get; }
        [UsedImplicitly][Field(Order=1000220)] public Int32 Size { get; }
        [UsedImplicitly][Field(Order=1000240)] public String DefaultValue { get; }
        [UsedImplicitly][Field(Order=1000230)] public String Expression { get; }
        }
    }
