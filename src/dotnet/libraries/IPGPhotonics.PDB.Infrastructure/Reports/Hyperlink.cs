using System;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    public class Hyperlink : FastReportObject
        {
        [UsedImplicitly][Field] public String DetailPageName { get; }
        [UsedImplicitly][Field] public String DetailReportName { get; }
        [UsedImplicitly][Field] public String Expression { get; }
        [UsedImplicitly][Field] public String ReportParameter { get; }
        [UsedImplicitly][Field] public String Value { get; }
        [UsedImplicitly][Field] public String ValuesSeparator { get; }
        [UsedImplicitly][Field] public HyperlinkKind Kind { get; }
        }
    }