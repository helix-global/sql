using System;
using System.ComponentModel;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;

    [FastReportClass("Style")]
    internal sealed class FastReportStyle : FastReportStyleBase
        {
        [UsedImplicitly][Field(Order=1000001)] public String Name { get; }
        [UsedImplicitly][Field(Order=1000105)][DefaultValue(true)] public override Boolean ApplyBorder { get; } = true;
        [UsedImplicitly][Field(Order=1000108)][DefaultValue(true)] public override Boolean ApplyFont { get; } = true;
        }
    }