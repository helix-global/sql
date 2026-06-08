using System;
using System.ComponentModel;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("TableColumn")]
    internal sealed class TableColumn : ComponentBase
        {
        [UsedImplicitly][Field(Order=1000304)] public Boolean AutoSize { get; }
        //[UsedImplicitly][Field(Order=1000300)] public Boolean PageBreak { get; }
        //[UsedImplicitly][Field(Order=1000300)] public Int32 KeepColumns { get; }
        [UsedImplicitly][Field(Order=1000302,ConverterCulture="en-US")][DefaultValue(500f)] public Single MaxWidth { get; } = 500f;
        [UsedImplicitly][Field(Order=1000301,ConverterCulture="en-US")] public Single MinWidth { get; }
        [UsedImplicitly][Field(Order=1000303,ConverterCulture="en-US")] public override Single Width { get; }
        }
    }
