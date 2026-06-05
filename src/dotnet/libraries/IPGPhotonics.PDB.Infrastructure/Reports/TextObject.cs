using System;
using System.ComponentModel;
using System.Drawing;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    using StringTrimming=System.Drawing.StringTrimming;

    [FastReportClass("TextObject")]
    internal class TextObject : TextObjectBase
        {
        protected internal override String ClassName { get { return "TextObject"; }}
        [UsedImplicitly][Field(Order=1000604)] public HorzAlign HorzAlign { get; }
        [UsedImplicitly][Field(Order=1000605)] public VertAlign VertAlign { get; }
        [UsedImplicitly][Field(Order=1000610)] public String Font { get; }
        [UsedImplicitly][Field(Order=1000611)][DefaultValue(KnownColor.Black)] public FillBase TextFill { get; } = new SolidFill(Color.Black);
        [UsedImplicitly][Field(Order=1000600,Converter=typeof(SqlColorConverter))] public Color TextColor { get; }
        [UsedImplicitly][Field(Order=1000606)] public Int32 Angle { get; }
        [UsedImplicitly][Field(Order=1000602)] public AutoShrinkMode AutoShrink { get; }
        [UsedImplicitly][Field(Order=1000603,ConverterCulture="en-US")] public Single AutoShrinkMinSize { get; }
        [UsedImplicitly][Field(Order=1000614,ConverterCulture="en-US")] public Single FirstTabOffset { get; }
        [UsedImplicitly][Field(Order=1000613,ConverterCulture="en-US")][DefaultValue(1f)] public Single FontWidthRatio { get; } = 1f;
        [UsedImplicitly][Field(Order=1000618,ConverterCulture="en-US")] public Single LineHeight { get; }
        [UsedImplicitly][Field(Order=1000620,ConverterCulture="en-US")] public Single ParagraphOffset { get; }
        [UsedImplicitly][Field(Order=1000615,ConverterCulture="en-US")] public Single TabWidth { get; }
        [UsedImplicitly][Field(Order=1000601)] public Boolean AutoWidth { get; }
        [UsedImplicitly][Field(Order=1000616)][DefaultValue(true)] public Boolean Clip { get; } = true;
        [UsedImplicitly][Field(Order=1000621)] public Boolean ForceJustify { get; }
        [UsedImplicitly][Field(Order=1000619)] public Boolean HtmlTags { get; }
        [UsedImplicitly][Field(Order=1000607)] public Boolean RightToLeft { get; }
        [UsedImplicitly][Field(Order=1000609)] public Boolean Underlines { get; }
        [UsedImplicitly][Field(Order=1000608)][DefaultValue(true)] public Boolean WordWrap { get; } = true;
        [UsedImplicitly][Field(Order=1000617)][DefaultValue(true)] public Boolean Wysiwyg { get; } = true;
        [UsedImplicitly][Field(Order=1000622)] public override String Style { get; }
        [UsedImplicitly][Field(Order=1000612,Converter=typeof(SqlEnumConverter<StringTrimming>))] public StringTrimming Trimming { get; }
        }
    }
