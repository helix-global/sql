using System;
using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;

    [FastReportClass("Condition")]
    internal sealed class HighlightCondition : StyleBase
        {
        [UsedImplicitly][Field(Order=1000001)] public String Expression { get; }
        [UsedImplicitly][Field(Order=1000002)] public Boolean Visible { get; }
        [UsedImplicitly][Field(Order=1000106)][DefaultValue(false)] public override Boolean ApplyFill { get; }
        }
    }