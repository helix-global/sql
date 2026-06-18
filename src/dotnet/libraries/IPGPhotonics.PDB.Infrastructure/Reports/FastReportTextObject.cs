using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;

    [FastReportClass("TextObject")]
    internal class FastReportTextObject : FastReportTextObjectBase
        {
        [UsedImplicitly][Field(Order=1000604)] public HorzAlign HorzAlign { get; }
        [UsedImplicitly][Field(Order=1000605)] public VertAlign VertAlign { get; }
        [UsedImplicitly][Field(Order=1000610)] public String Font { get; }
        [UsedImplicitly][Field(Order=1000611)][DefaultValue(typeof(FastReportSolidFill),"Color=Black")] public FastReportFillBase TextFill { get; } = new FastReportSolidFill(Color.Black);
        [UsedImplicitly][Field(Order=1000600,Converter=typeof(FastReportColorConverter))] public Color TextColor { get; }
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
        [UsedImplicitly][Field(Order=1000617)][DefaultValue(false)] public Boolean Wysiwyg { get; } = false;
        [UsedImplicitly][Field(Order=1000622)] public override String Style { get; }
        [UsedImplicitly][Field(Order=1000612,Converter=typeof(SqlEnumConverter<StringTrimming>))] public StringTrimming Trimming { get; }
        [UsedImplicitly][Field("Highlight",EmptyIfNull=true)] public IList<FastReportHighlightCondition> Highlights { get; }

        #region M:Serialize(IFastReportSerializer,String,Object)
        public override void Serialize(IFastReportSerializer serializer,String prefix,Object other) {
            if (serializer == null) { throw new ArgumentNullException(nameof(serializer)); }
            serializer.Serialize(this,prefix,other);
            }
        #endregion
        }
    }
