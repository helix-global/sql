using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;

    /// <summary>
    /// Represents the Text object that may display one or several text lines.
    /// </summary>
    [FastReportClass("TextObject")]
    internal class FastReportTextObject : FastReportTextObjectBase
        {
        /// <summary>
        /// Gets the horizontal alignment of a text in the <b>TextObject</b> object.
        /// </summary>
        [UsedImplicitly][Field(Order=1000604)] public HorzAlign HorzAlign { get; }
        /// <summary>
        /// Gets the vertical alignment of a text in the <b>TextObject</b> object.
        /// </summary>
        [UsedImplicitly][Field(Order=1000605)] public VertAlign VertAlign { get; }
        /// <summary>
        /// Gets the font settings for this object.
        /// </summary>
        [UsedImplicitly][Field(Order=1000610)] public String Font { get; }
        /// <summary>
        /// Gets the fill color used to draw a text.
        /// </summary>
        [UsedImplicitly][Field(Order=1000611)][DefaultValue(typeof(FastReportSolidFill),"Color=Black")] public FastReportFillBase TextFill { get; } = new FastReportSolidFill(Color.Black);
        /// <summary>
        /// Gets the text color in a simple manner.
        /// </summary>
        [UsedImplicitly][Field(Order=1000600,Converter=typeof(FastReportColorConverter))] public Color TextColor { get; }
        /// <summary>
        /// Gets the text angle, in degrees.
        /// </summary>
        [UsedImplicitly][Field(Order=1000606)] public Int32 Angle { get; }
        /// <summary>
        /// Gets a value that indicates whether the font size should shrink to
        /// display the longest text line without word wrap.
        /// </summary>
        [UsedImplicitly][Field(Order=1000602)] public AutoShrinkMode AutoShrink { get; }
        /// <summary>
        /// Gets the minimum size of font (or minimum width ratio) if the <see cref="AutoShrink"/>
        /// mode is on.
        /// </summary>
        [UsedImplicitly][Field(Order=1000603,ConverterCulture="en-US")] public Single AutoShrinkMinSize { get; }
        /// <summary>
        /// Gets the offset, in pixels, of the first TAB symbol.
        /// </summary>
        [UsedImplicitly][Field(Order=1000614,ConverterCulture="en-US")] public Single FirstTabOffset { get; }
        /// <summary>
        /// Gets the width ratio of the font. 
        /// </summary>
        [UsedImplicitly][Field(Order=1000613,ConverterCulture="en-US")][DefaultValue(1f)] public Single FontWidthRatio { get; } = 1f;
        /// <summary>
        /// Gets the height of single text line, in pixels.
        /// </summary>
        [UsedImplicitly][Field(Order=1000618,ConverterCulture="en-US")] public Single LineHeight { get; }
        /// <summary>
        /// Gets the paragraph offset, in pixels.
        /// </summary>
        [UsedImplicitly][Field(Order=1000620,ConverterCulture="en-US")] public Single ParagraphOffset { get; }
        /// <summary>
        /// Gets the width of TAB symbol, in pixels.
        /// </summary>
        [UsedImplicitly][Field(Order=1000615,ConverterCulture="en-US")] public Single TabWidth { get; }
        /// <summary>
        /// Gets a value that determines if the text object should handle its width automatically.
        /// </summary>
        [UsedImplicitly][Field(Order=1000601)] public Boolean AutoWidth { get; }
        /// <summary>
        /// Gets a value that indicates if text should be clipped inside the object's bounds.
        /// </summary>
        [UsedImplicitly][Field(Order=1000616)][DefaultValue(true)] public Boolean Clip { get; } = true;
        /// <summary>
        /// Forces justify for the last text line.
        /// </summary>
        [UsedImplicitly][Field(Order=1000621)] public Boolean ForceJustify { get; }
        /// <summary>
        /// Allows handling html tags in the text.
        /// </summary>
        [UsedImplicitly][Field(Order=1000619)] public Boolean HtmlTags { get; }
        /// <summary>
        /// Gets a value that indicates whether the component should draw right-to-left for RTL languages.
        /// </summary>
        [UsedImplicitly][Field(Order=1000607)] public Boolean RightToLeft { get; }
        /// <summary>
        /// Gets a value that determines if the text object will underline each text line.
        /// </summary>
        [UsedImplicitly][Field(Order=1000609)] public Boolean Underlines { get; }
        /// <summary>
        /// Gets a value that indicates if lines are automatically word-wrapped.
        /// </summary>
        [UsedImplicitly][Field(Order=1000608)][DefaultValue(true)] public Boolean WordWrap { get; } = true;
        /// <summary>
        /// Gets a value that indicates if the text object should display its contents similar to the printout.
        /// </summary>
        [UsedImplicitly][Field(Order=1000617)][DefaultValue(false)] public Boolean Wysiwyg { get; } = false;
        [UsedImplicitly][Field(Order=1000622)] public override String Style { get; }
        /// <summary>
        /// Gets the string trimming options.
        /// </summary>
        [UsedImplicitly][Field(Order=1000612,Converter=typeof(SqlEnumConverter<StringTrimming>))] public StringTrimming Trimming { get; }
        /// <summary>
        /// Gets the collection of conditional highlight attributes.
        /// </summary>
        [UsedImplicitly][Field("Highlight",EmptyIfNull=true)] public IList<FastReportHighlightCondition> Highlights { get; }

        #region M:Serialize(IFastReportSerializer,String,Object)
        public override void Serialize(IFastReportSerializer serializer,String prefix,Object other) {
            if (serializer == null) { throw new ArgumentNullException(nameof(serializer)); }
            serializer.Serialize(this,prefix,other);
            }
        #endregion
        }
    }
