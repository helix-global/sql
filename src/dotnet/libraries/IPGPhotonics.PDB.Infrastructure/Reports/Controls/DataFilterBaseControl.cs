using System;
using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class DataFilterBaseControl : DialogControl
        {
        [UsedImplicitly][Field(Order=1000501)][DefaultValue(true)] public Boolean AutoFill { get; } = true;
        [UsedImplicitly][Field(Order=1000502)][DefaultValue(true)] public Boolean AutoFilter { get; } = true;
        [UsedImplicitly][Field(Order=1000503)] public String DataColumn { get; }
        [UsedImplicitly][Field(Order=1000507)] public String DataLoadedEvent { get; }
        [UsedImplicitly][Field(Order=1000504)] public String ReportParameter { get; }
        [UsedImplicitly][Field(Order=1000506)] public String DetailControl { get; }
        [UsedImplicitly][Field(Order=1000505)] public FilterOperation FilterOperation { get; }
        }
    }
