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
    public class PictureObject : ReportComponentBase
        {
        [UsedImplicitly][Field(Converter=typeof(SqlThicknessConverter))] public Thickness Padding { get; }
        [UsedImplicitly][Field(Converter=typeof(SqlArrayConverter))] public Byte[] Image { get; }
        [UsedImplicitly][Field(Converter=typeof(SqlEnumConverter<PictureBoxSizeMode>))] public PictureBoxSizeMode SizeMode { get; } = PictureBoxSizeMode.Zoom;
        [UsedImplicitly][Field] public Int32 Angle { get; }
        [UsedImplicitly][Field] public String DataColumn { get; }
        [UsedImplicitly][Field] public String ImageLocation { get; }
        [UsedImplicitly][Field] public Single MaxHeight { get; }
        [UsedImplicitly][Field] public Single MaxWidth { get; }
        [UsedImplicitly][Field] public Boolean ShowErrorImage { get; }
        [UsedImplicitly][Field] public Boolean Tile { get; }
        [UsedImplicitly][Field] public Single Transparency { get; }
        [UsedImplicitly][Field(Converter=typeof(SqlColorConverter))] public Color TransparentColor { get; }
        }
    }
