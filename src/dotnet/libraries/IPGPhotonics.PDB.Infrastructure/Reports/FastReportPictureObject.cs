using System;
using System.ComponentModel;
using System.Windows;
using System.Windows.Forms;
using System.Windows.Media;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("PictureObject")]
    internal class FastReportPictureObject : ReportComponentBase
        {
        [UsedImplicitly][Field(Order=1000404,Converter=typeof(FastReportThicknessConverter))] public Thickness Padding { get; }
        [UsedImplicitly][Field(Order=1000412,Converter=typeof(SqlBase64ArrayConverter))] public Byte[] Image { get; }
        [UsedImplicitly][Field(Order=1000401,Converter=typeof(SqlEnumConverter<PictureBoxSizeMode>))][DefaultValue(PictureBoxSizeMode.Zoom)] public PictureBoxSizeMode SizeMode { get; } = PictureBoxSizeMode.Zoom;
        [UsedImplicitly][Field(Order=1000411)] public Int32 Angle { get; }
        [UsedImplicitly][Field(Order=1000413)] public Int32 ImageIndex { get; }
        [UsedImplicitly][Field(Order=1000406)] public String DataColumn { get; }
        [UsedImplicitly][Field(Order=1000405)] public String ImageLocation { get; }
        [UsedImplicitly][Field(Order=1000403,ConverterCulture="en-US")] public Single MaxHeight { get; }
        [UsedImplicitly][Field(Order=1000402,ConverterCulture="en-US")] public Single MaxWidth { get; }
        [UsedImplicitly][Field(Order=1000408,ConverterCulture="en-US")] public Single Transparency { get; }
        [UsedImplicitly][Field(Order=1000407,Converter=typeof(FastReportColorConverter))] public Color TransparentColor { get; }
        [UsedImplicitly][Field(Order=1000409)] public Boolean ShowErrorImage { get; }
        [UsedImplicitly][Field(Order=1000410)] public Boolean Tile { get; }

        #region M:Serialize(IFastReportSerializer,String,Object)
        public override void Serialize(IFastReportSerializer serializer,String prefix,Object other) {
            if (serializer == null) { throw new ArgumentNullException(nameof(serializer)); }
            serializer.Serialize(this,prefix,other);
            }
        #endregion
        }
    }
