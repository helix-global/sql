using System;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;

    [FastReportClass("Highlight")]
    [FastReportClass("Condition")]
    public class HighlightCondition : StyleBase
        {
        [UsedImplicitly][Field] public String Expression { get; }
        [UsedImplicitly][Field] public Boolean Visible { get; }
        }
    }