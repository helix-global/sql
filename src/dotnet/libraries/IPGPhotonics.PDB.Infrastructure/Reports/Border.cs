using System;
using System.ComponentModel;
using System.Drawing;
using System.Xml;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal sealed class Border : FastReportObject
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

        [UsedImplicitly][Field(ConverterCulture="en-US")] public Single Width
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

        [UsedImplicitly][Field] public BorderLine BottomLine { get; } = new BorderLine();
        [UsedImplicitly][Field] public BorderLine LeftLine   { get; } = new BorderLine();
        [UsedImplicitly][Field] public BorderLine RightLine  { get; } = new BorderLine();
        [UsedImplicitly][Field] public BorderLine TopLine    { get; } = new BorderLine();

        #region M:Serialize(XmlWriter,String)
        public override void Serialize(XmlWriter writer,String prefix) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            if (Shadow) { writer.WriteAttribute($"{prefix}.Shadow","true"); }
            if (ShadowWidth != 4f) { writer.WriteAttribute($"{prefix}.ShadowWidth",ShadowWidth); }
            if (ShadowColor != Color.Black) { writer.WriteAttribute($"{prefix}.ShadowColor",FastReportColorConverter.Instance.ConvertToInvariantString(ShadowColor)); }
            if (!SimpleBorder) {
                if (Lines > 0) {
                    writer.WriteAttribute($"{prefix}.Lines",Lines);
                    if (LeftLine.Equals(RightLine) && LeftLine.Equals(TopLine) && LeftLine.Equals(BottomLine)) {
                        LeftLine.Serialize(writer,prefix);
                        return;
                        }
                    LeftLine.Serialize(writer,$"{prefix}.LeftLine");
                    TopLine.Serialize(writer,$"{prefix}.TopLine");
                    RightLine.Serialize(writer,$"{prefix}.RightLine");
                    BottomLine.Serialize(writer,$"{prefix}.BottomLine");
                    }
                }
            else
                {
                LeftLine.Serialize(writer,prefix);
                }
            }
        #endregion
        }
    }