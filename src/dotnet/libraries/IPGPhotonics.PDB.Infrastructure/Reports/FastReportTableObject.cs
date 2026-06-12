using System;
using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("TableObject")]
    internal sealed class FastReportTableObject : FastReportTableBase
        {
        [UsedImplicitly][Field(Order=1000602)][DefaultValue(true)] public Boolean ManualBuildAutoSpans { get; } = true;
        [UsedImplicitly][Field(Order=1000601)] public String ManualBuildEvent { get; }
        }
    }
