using System;
using System.ComponentModel;
using System.Drawing;
using System.Xml;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [TypeConverter(typeof(SqlObjectConverter<FastReportWatermark>))]
    internal sealed class FastReportWatermark : FastReportObject,IFastReportClassObject,IEquatable<FastReportWatermark>
        {
        String IFastReportClassObject.ClassName { get { return "Watermark"; } }
        [UsedImplicitly][Field(Order=1000101)] public Boolean Enabled { get; }
        [UsedImplicitly][Field(Order=1000110)] public Boolean ShowImageOnTop { get; }
        [UsedImplicitly][Field(Order=1000109)][DefaultValue(true)] public Boolean ShowTextOnTop { get; } = true;
        [UsedImplicitly][Field(Order=1000106)] public String Font { get; }
        [UsedImplicitly][Field(Order=1000105)] public String Text { get; }
        [UsedImplicitly][Field(Order=1000102,Converter=typeof(SqlArrayConverter))] public Byte[] Image { get; }
        [UsedImplicitly][Field(Order=1000103)][DefaultValue(WatermarkImageSize.Zoom)] public WatermarkImageSize ImageSize { get; } = WatermarkImageSize.Zoom;
        [UsedImplicitly][Field(Order=1000108)][DefaultValue(WatermarkTextRotation.ForwardDiagonal)] public WatermarkTextRotation TextRotation { get; } = WatermarkTextRotation.ForwardDiagonal;
        [UsedImplicitly][Field(Order=1000104,ConverterCulture="en-US")] public Single ImageTransparency { get; }
        [UsedImplicitly][Field(Order=1000107)][DefaultValue(typeof(FastReportSolidFill),"Color=#28808080")] public FastReportFillBase TextFill { get; } = new FastReportSolidFill(Color.FromArgb(40,Color.Gray));

        #region M:Serialize(XmlWriter,String,Object)
        public override void Serialize(XmlWriter writer,String prefix,Object other) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            SerializeAttributes(writer,prefix);
            }
        #endregion
        #region M:Equals(Object):Boolean
        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns>true if the current object is equal to the other parameter; otherwise, false.</returns>
        public override Boolean Equals(Object other) {
            if (ReferenceEquals(other,null)) { return false; }
            if (ReferenceEquals(this,other)) { return true;  }
            return Equals(other as FastReportWatermark);
            }
        #endregion
        #region M:Equals(FastReportWatermark):Boolean
        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns>true if the current object is equal to the other parameter; otherwise, false.</returns>
        public Boolean Equals(FastReportWatermark other) {
            if (ReferenceEquals(other,null)) { return false; }
            if (ReferenceEquals(this,other)) { return true;  }
            return (Enabled==other.Enabled)
                && (ShowImageOnTop==other.ShowImageOnTop)
                && (ShowTextOnTop==other.ShowTextOnTop)
                && (ImageTransparency==other.ImageTransparency)
                && (ImageSize==other.ImageSize)
                && (TextRotation==other.TextRotation)
                && String.Equals(Font,other.Font)
                && String.Equals(Text,other.Text)
                && SqlArrayConverter.Equals(Image,other.Image)
                && FastReportFillBase.Equals(TextFill,other.TextFill);
            }
        #endregion
        #region M:GetHashCode:Int32
        /// <summary>Calculates a hash code for the current object.</summary>
        /// <returns>Returns a hash code for the current object.</returns>
        public override Int32 GetHashCode() {
            return HashCodeCombiner.GetHashCode(
                Enabled,ShowImageOnTop,ShowTextOnTop,
                Font,Text,ImageTransparency,
                ImageSize,TextRotation,Image,TextFill);
            }
        #endregion
        }
    }