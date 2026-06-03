using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics.CodeAnalysis;
using System.Drawing;
using System.Drawing.Printing;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("ReportPage")]
    internal sealed class ReportPage : PageBase
        {
        [UsedImplicitly][Field(Order=1000414,Converter=typeof(SqlSingleCollectionConverter))] public IList<Single> Guides { get; }
        [UsedImplicitly][Field(Order=1000412,Converter=typeof(SqlEnumConverter<Duplex>))][DefaultValue(Duplex.Default)] public Duplex Duplex { get; } = Duplex.Default;
        [UsedImplicitly][Field(Order=1000422)][DefaultValue(false)] public Boolean ExtraDesignWidth { get; }
        [UsedImplicitly][Field(Order=1000424)][DefaultValue(false)] public Boolean BackPage { get; }
        [UsedImplicitly][Field(Order=1000401)][DefaultValue(false)] public Boolean Landscape { get; }
        [UsedImplicitly][Field(Order=1000409)][DefaultValue(false)] public Boolean MirrorMargins { get; }
        [UsedImplicitly][Field(Order=1000420)][DefaultValue(false)] public Boolean PrintOnPreviousPage { get; }
        [UsedImplicitly][Field(Order=1000421)][DefaultValue(false)] public Boolean ResetPageNumber { get; }
        [UsedImplicitly][Field(Order=1000423)][DefaultValue(false)] public Boolean StartOnOddPage { get; }
        [UsedImplicitly][Field(Order=1000418)][DefaultValue(true)] public Boolean TitleBeforeHeader { get; } = true;
        [UsedImplicitly][Field(Order=1000408)][DefaultValue(0f)] public Single BottomMargin { get; }
        [UsedImplicitly][Field(Order=1000405)][DefaultValue(0f)] public Single LeftMargin { get; }
        [UsedImplicitly][Field(Order=1000403)][DefaultValue(0f)] public Single PaperHeight { get; }
        [UsedImplicitly][Field(Order=1000402)][DefaultValue(0f)] public Single PaperWidth { get; }
        [UsedImplicitly][Field(Order=1000407)][DefaultValue(0f)] public Single RightMargin { get; }
        [UsedImplicitly][Field(Order=1000406)][DefaultValue(0f)] public Single TopMargin { get; }
        [UsedImplicitly][Field(Order=1000426)] public String FinishPageEvent { get; }
        [UsedImplicitly][Field(Order=1000427)] public String ManualBuildEvent { get; }
        [UsedImplicitly][Field(Order=1000419)] public String OutlineExpression { get; }
        [UsedImplicitly][Field(Order=1000425)] public String StartPageEvent { get; }
        [UsedImplicitly][Field(Order=1000410)][DefaultValue(7)] public Int32 FirstPageSource { get; } = 7;
        [UsedImplicitly][Field(Order=1000411)][DefaultValue(7)] public Int32 OtherPagesSource { get; } = 7;
        [UsedImplicitly][Field(Order=1000404)][DefaultValue(0)] public Int32 RawPaperSize { get; }
        [UsedImplicitly][Field(Order=1000415)] public Border Border { get; } = new Border();
        [UsedImplicitly][Field(Order=1000416)][DefaultValue(KnownColor.Window)] public FillBase Fill { get; } = new SolidFill(SystemColors.Window);
        [UsedImplicitly][Field(Order=1000413)] public PageColumns Columns { get; } = new PageColumns();
        [UsedImplicitly][Field(Order=1000417)] public Watermark Watermark { get; } = new Watermark();
        public IList<BandBase> Bands { get; } = new SqlObjectCollection<BandBase>();
        public override IEnumerable<FastReportObject> Children { get {
            foreach (var o in Bands) {
                yield return o;
                }
            }}

        #region M:UpdateReferences(IList<FastReportObject>)
        [SuppressMessage("ReSharper", "LocalVariableHidesMember")]
        protected override void UpdateReferences(IList<FastReportObject> source) {
            using (var Bands = PrepareChanges(this.Bands)) {
                foreach (var o in source) {
                    if (o is BandBase BandBase) {
                        Bands.Add(BandBase);
                        }
                    }
                }
            }
        #endregion
        }
    }
