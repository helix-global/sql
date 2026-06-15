using System;
using System.ComponentModel;
using System.Diagnostics;
using System.Drawing;
using System.Xml;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [TypeConverter(typeof(SqlObjectConverter<FastReportBorder>))]
    internal sealed class FastReportBorder : FastReportObject,IFastReportClassObject,IEquatable<FastReportBorder>
        {
        String IFastReportClassObject.ClassName { get { return "Border"; }}
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

        [UsedImplicitly][Field(Converter=typeof(FastReportColorConverter))][DefaultValue("Black")] public Color ShadowColor { get; } = Color.Black;
        [UsedImplicitly][Field] public Boolean Shadow { get; }
        [UsedImplicitly][Field(ConverterCulture="en-US")][DefaultValue(4f)] public Single ShadowWidth { get; } = 4f;
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

        [UsedImplicitly][Field][DefaultValue(typeof(FastReportBorderLine),null)] public FastReportBorderLine BottomLine { get; } = new FastReportBorderLine();
        [UsedImplicitly][Field][DefaultValue(typeof(FastReportBorderLine),null)] public FastReportBorderLine LeftLine   { get; } = new FastReportBorderLine();
        [UsedImplicitly][Field][DefaultValue(typeof(FastReportBorderLine),null)] public FastReportBorderLine RightLine  { get; } = new FastReportBorderLine();
        [UsedImplicitly][Field][DefaultValue(typeof(FastReportBorderLine),null)] public FastReportBorderLine TopLine    { get; } = new FastReportBorderLine();

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
        #region M:Equals(Object):Boolean
        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns>true if the current object is equal to the other parameter; otherwise, false.</returns>
        public override Boolean Equals(Object other)
            {
            if (ReferenceEquals(other,null)) { return false; }
            if (ReferenceEquals(this,other)) { return true;  }
            return Equals(other as FastReportBorder);
            }
        #endregion
        #region M:Equals(FastReportBorder):Boolean
        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns>true if the current object is equal to the other parameter; otherwise, false.</returns>
        public Boolean Equals(FastReportBorder other) {
            if (ReferenceEquals(other,null)) { return false; }
            if (ReferenceEquals(this,other)) { return true;  }
            var r = (Lines == other.Lines)
                && (ShadowColor == other.ShadowColor)
                && (Shadow == other.Shadow)
                && (ShadowWidth == other.ShadowWidth)
                && (SimpleBorder == other.SimpleBorder)
                && FastReportBorderLine.Equals(LeftLine,other.LeftLine)
                && FastReportBorderLine.Equals(TopLine,other.TopLine)
                && FastReportBorderLine.Equals(RightLine,other.RightLine)
                && FastReportBorderLine.Equals(BottomLine,other.BottomLine);
            if (!r)
                {
                //Debugger.Break();
                }
            return r;
            }
        #endregion
        #region M:GetHashCode:Int32
        /// <summary>Calculates a hash code for the current object.</summary>
        /// <returns>A hash code for the current object.</returns>
        public override Int32 GetHashCode() {
            return HashCodeCombiner.GetHashCode(
                Lines,ShadowColor,Shadow,
                ShadowWidth,SimpleBorder,LeftLine,
                TopLine,RightLine,BottomLine);
            }
        #endregion
        }
    }