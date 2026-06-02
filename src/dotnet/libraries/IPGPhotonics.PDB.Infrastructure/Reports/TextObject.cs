using System;
using System.ComponentModel;
using System.Windows.Media;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;
using Color = System.Drawing.Color;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    using StringTrimming=System.Drawing.StringTrimming;

    [FastReportClass("TextObject")]
    internal class TextObject : TextObjectBase
        {
        protected internal override String ClassName { get { return "TextObject"; }}
        [UsedImplicitly][Field] public HorzAlign HorzAlign { get; }
        [UsedImplicitly][Field] public VertAlign VertAlign { get; }
        [UsedImplicitly][Field] public String Font { get; }
        [UsedImplicitly][Field] public FillBase TextFill { get; } = new SolidFill(Color.Black);
        [UsedImplicitly][Field(Converter=typeof(SqlColorConverter))] public Color TextColor { get; }
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
        [UsedImplicitly][Field(Converter=typeof(SqlEnumConverter<StringTrimming>))] public StringTrimming Trimming { get; }

        #region M:Accept(IFastReportVisitor)
        public override void Accept(IFastReportVisitor visitor)
            {
            if (visitor == null) { throw new ArgumentNullException(nameof(visitor)); }
            visitor.Visit(this);
            }
        #endregion
        }
    }
