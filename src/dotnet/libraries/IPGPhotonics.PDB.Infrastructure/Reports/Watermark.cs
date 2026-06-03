using System;
using System.ComponentModel;
using System.Drawing;
using System.Xml;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal sealed class Watermark : FastReportObject
        {
        [UsedImplicitly][Field(Order=1000101)][DefaultValue(false)] public Boolean Enabled { get; }
        [UsedImplicitly][Field(Order=1000110)][DefaultValue(false)] public Boolean ShowImageOnTop { get; }
        [UsedImplicitly][Field(Order=1000109)][DefaultValue(true)] public Boolean ShowTextOnTop { get; } = true;
        [UsedImplicitly][Field(Order=1000106)] public String Font { get; }
        [UsedImplicitly][Field(Order=1000105)] public String Text { get; }
        [UsedImplicitly][Field(Order=1000102,Converter=typeof(SqlArrayConverter))] public Byte[] Image { get; }
        [UsedImplicitly][Field(Order=1000103)][DefaultValue(WatermarkImageSize.Zoom)] public WatermarkImageSize ImageSize { get; } = WatermarkImageSize.Zoom;
        [UsedImplicitly][Field(Order=1000108)][DefaultValue(WatermarkTextRotation.ForwardDiagonal)] public WatermarkTextRotation TextRotation { get; } = WatermarkTextRotation.ForwardDiagonal;
        [UsedImplicitly][Field(Order=1000104)][DefaultValue(0f)] public Single ImageTransparency { get; }
        [UsedImplicitly][Field(Order=1000107)] public FillBase TextFill { get; } = new SolidFill(Color.FromArgb(40,Color.Gray));

        #region M:Accept(IFastReportVisitor)
        public override void Accept(IFastReportVisitor visitor)
            {
            throw new NotImplementedException();
            }
        #endregion
        #region M:Serialize(XmlWriter,String)
        public override void Serialize(XmlWriter writer,String prefix) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            SerializeAttributes(writer,this,prefix,(descriptor)=>{
                switch (descriptor.Name) {
                    case nameof(TextFill):
                        {
                        if (TextFill is SolidFill sf) {
                            return (sf.Color.A != 40) && (sf.Color != Color.Gray);
                            }
                        return true;
                        }
                    default:
                        return true;
                    }
                });
            }
        #endregion
        }
    }