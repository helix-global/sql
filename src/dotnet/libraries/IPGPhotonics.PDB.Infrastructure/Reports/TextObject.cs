using System;
using System.ComponentModel;
using System.Windows.Media;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;
using IPGPhotonics.PDB.Infrastructure.Reports;

namespace IPGPhotonics.PDB.Infrastructure
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    using StringTrimming=System.Drawing.StringTrimming;

    [FastReportClass("TextObject")]
    public class TextObject : TextObjectBase
        {
        [UsedImplicitly][Field] public HorzAlign HorzAlign { get; }
        [UsedImplicitly][Field] public VertAlign VertAlign { get; }
        [UsedImplicitly][Field] public String Font { get; }
        [UsedImplicitly][Field("TextFill.Color")][TypeConverter(typeof(SqlColorConverter))] public Color TextFillColor { get; }
        [UsedImplicitly][TypeConverter(typeof(SqlColorConverter))] public Color TextColor { get; }
        [UsedImplicitly][Field] public Int32 Angle { get; }
        [UsedImplicitly][Field] public AutoShrinkMode AutoShrink { get; }
        [UsedImplicitly][Field] public Single AutoShrinkMinSize { get; }
        [UsedImplicitly][Field] public Single FirstTabOffset { get; }
        [UsedImplicitly][Field] public Single FontWidthRatio { get; } = 1f;
        [UsedImplicitly][Field] public Single LineHeight { get; }
        [UsedImplicitly][Field] public Single ParagraphOffset { get; }
        [UsedImplicitly][Field] public Single TabWidth { get; }
        [UsedImplicitly][Field] public Boolean AutoWidth { get; }
        [UsedImplicitly][Field] public Boolean Clip { get; } = true;
        [UsedImplicitly][Field] public Boolean ForceJustify { get; }
        [UsedImplicitly][Field] public Boolean HtmlTags { get; }
        [UsedImplicitly][Field] public Boolean RightToLeft { get; }
        [UsedImplicitly][Field] public Boolean Underlines { get; }
        [UsedImplicitly][Field] public Boolean WordWrap { get; } = true;
        [UsedImplicitly][Field] public Boolean Wysiwyg { get; } = true;
        [UsedImplicitly][Field] public StringTrimming Trimming { get; }
        }
    }
