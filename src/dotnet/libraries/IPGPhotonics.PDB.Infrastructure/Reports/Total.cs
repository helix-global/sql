using System;
using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("Total")]
    internal sealed class Total : Base
        {
        [UsedImplicitly][Field(Order=1000207)] public String EvaluateCondition { get; }
        [UsedImplicitly][Field(Order=1000202)] public String Expression { get; }
        [UsedImplicitly][Field(Order=1000203)] public String Evaluator { get; }
        [UsedImplicitly][Field(Order=1000204)] public String PrintOn { get; }
        [UsedImplicitly][Field(Order=1000208)] public Boolean IncludeInvisibleRows { get; }
        [UsedImplicitly][Field(Order=1000205)][DefaultValue(true)] public Boolean ResetAfterPrint { get; } = true;
        [UsedImplicitly][Field(Order=1000206)]public Boolean ResetOnReprint { get; }
        [UsedImplicitly][Field(Order=1000201)] public TotalType TotalType { get; }
        }
    }
