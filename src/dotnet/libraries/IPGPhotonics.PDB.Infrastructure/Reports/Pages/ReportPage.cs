using System;
using System.Collections.Generic;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("ReportPage")]
    internal sealed class ReportPage : PageBase
        {
        [UsedImplicitly][Field(Converter=typeof(SqlSingleCollectionConverter))] public IList<Single> Guides { get; }
        [UsedImplicitly][Field] public Boolean BackPage { get; }
        [UsedImplicitly][Field] public Boolean Landscape { get; }
        [UsedImplicitly][Field] public Boolean MirrorMargins { get; }
        [UsedImplicitly][Field] public Boolean PrintOnPreviousPage { get; }
        [UsedImplicitly][Field] public Boolean ResetPageNumber { get; }
        [UsedImplicitly][Field] public Boolean StartOnOddPage { get; }
        [UsedImplicitly][Field] public Boolean TitleBeforeHeader { get; } = true;
        [UsedImplicitly][Field] public Single BottomMargin { get; }
        [UsedImplicitly][Field] public Single LeftMargin { get; }
        [UsedImplicitly][Field] public Single PaperHeight { get; }
        [UsedImplicitly][Field] public Single PaperWidth { get; }
        [UsedImplicitly][Field] public Single RightMargin { get; }
        [UsedImplicitly][Field] public Single TopMargin { get; }
        [UsedImplicitly][Field] public String FinishPageEvent { get; }
        [UsedImplicitly][Field] public String ManualBuildEvent { get; }
        [UsedImplicitly][Field] public String OutlineExpression { get; }
        [UsedImplicitly][Field] public String StartPageEvent { get; }
        [UsedImplicitly][Field] public Int32 FirstPageSource { get; } = 7;
        [UsedImplicitly][Field] public Int32 OtherPagesSource { get; } = 7;
        [UsedImplicitly][Field] public Int32 RawPaperSize { get; }
        }
    }
