using System;
using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;

    [FastReportClass("TableRow")]
    internal sealed class TableRow : ComponentBase
        {
        protected internal override String ClassName { get { return "TableRow"; }}
        [UsedImplicitly][Field] public Boolean AutoSize { get; }
        [UsedImplicitly][Field] public Boolean KeepRows { get; }
        [UsedImplicitly][Field] public Boolean PageBreak { get; }
        [UsedImplicitly][Field(ConverterCulture="en-US")][DefaultValue(500f)] public Single MaxHeight { get; } = 500f;
        [UsedImplicitly][Field(ConverterCulture="en-US")] public Single MinHeight { get; }
        }
    }
