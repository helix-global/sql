using System;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("TableColumn")]
    internal sealed class TableColumn : ComponentBase
        {
        protected internal override String ClassName { get { return "TableColumn"; }}
        [UsedImplicitly][Field] public Boolean AutoSize { get; }
        [UsedImplicitly][Field] public Boolean PageBreak { get; }
        [UsedImplicitly][Field] public Int32 KeepColumns { get; }
        [UsedImplicitly][Field(ConverterCulture="en-US")] public Single MaxWidth { get; } = 500f;
        [UsedImplicitly][Field(ConverterCulture="en-US")] public Single MinWidth { get; }
        }
    }
