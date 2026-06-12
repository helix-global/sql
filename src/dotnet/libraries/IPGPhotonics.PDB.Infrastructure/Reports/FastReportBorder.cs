using System;
using System.ComponentModel;
using System.Drawing;
using System.Xml;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal sealed class FastReportBorder : FastReportObject
        {
        [UsedImplicitly][Field][DefaultValue(BorderLines.None)] public BorderLines Lines { get; }
        [UsedImplicitly][Field(Converter=typeof(FastReportColorConverter))] public Color Color
            {
            get { return LeftLine.Color; }
            set
                {
                BottomLine.Color = value;
                LeftLine.Color   = value;
                RightLine.Color  = value;
                TopLine.Color    = value;
                }
            }

        [UsedImplicitly][Field(Converter=typeof(FastReportColorConverter))] public Color ShadowColor { get; } = Color.Black;
        [UsedImplicitly][Field] public Boolean Shadow { get; }
        [UsedImplicitly][Field(ConverterCulture="en-US")] public Single ShadowWidth { get; } = 4f;
        public Boolean SimpleBorder { get;set; }

        [UsedImplicitly][Field(ConverterCulture="en-US")][DefaultValue(1f)] public Single Width
            {
            get { return LeftLine.Width; }
            set
                {
                BottomLine.Width = value;
                LeftLine.Width   = value;
                RightLine.Width  = value;
                TopLine.Width    = value;
                }
            }

        [UsedImplicitly][Field] public LineStyle Style
            {
            get { return LeftLine.Style; }
            set
                {
                BottomLine.Style = value;
                LeftLine.Style   = value;
                RightLine.Style  = value;
                TopLine.Style    = value;
                }
            }

        [UsedImplicitly][Field] public FastReportBorderLine BottomLine { get; } = new FastReportBorderLine();
        [UsedImplicitly][Field] public FastReportBorderLine LeftLine   { get; } = new FastReportBorderLine();
        [UsedImplicitly][Field] public FastReportBorderLine RightLine  { get; } = new FastReportBorderLine();
        [UsedImplicitly][Field] public FastReportBorderLine TopLine    { get; } = new FastReportBorderLine();

        #region M:Serialize(XmlWriter,String,Object)
        public override void Serialize(XmlWriter writer,String prefix,Object other) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            if (Shadow) { writer.WriteAttribute($"{prefix}.Shadow","true"); }
            if (ShadowWidth != 4f) { writer.WriteAttribute($"{prefix}.ShadowWidth",ShadowWidth); }
            if (ShadowColor != Color.Black) { writer.WriteAttribute($"{prefix}.ShadowColor",FastReportColorConverter.Instance.ConvertToInvariantString(ShadowColor)); }
            if (!SimpleBorder) {
                if (Lines > 0) {
                    writer.WriteAttribute($"{prefix}.Lines",Lines);
                    if (LeftLine.Equals(RightLine) && LeftLine.Equals(TopLine) && LeftLine.Equals(BottomLine)) {
                        LeftLine.Serialize(writer,prefix,null);
                        return;
                        }
                    LeftLine.Serialize(writer,$"{prefix}.LeftLine",null);
                    TopLine.Serialize(writer,$"{prefix}.TopLine",null);
                    RightLine.Serialize(writer,$"{prefix}.RightLine",null);
                    BottomLine.Serialize(writer,$"{prefix}.BottomLine",null);
                    }
                }
            else
                {
                LeftLine.Serialize(writer,prefix,null);
                }
            }
        #endregion
        }
    }