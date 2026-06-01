using System;
using System.Drawing;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal class Watermark : FastReportObject
        {
        [UsedImplicitly][Field] public Boolean Enabled { get; }
        [UsedImplicitly][Field] public Boolean ShowImageOnTop { get; }
        [UsedImplicitly][Field] public Boolean ShowTextOnTop { get; } = true;
        [UsedImplicitly][Field] public String Font { get; }
        [UsedImplicitly][Field] public String Text { get; }
        [UsedImplicitly][Field(Converter=typeof(SqlArrayConverter))] public Byte[] Image { get; }
        [UsedImplicitly][Field] public WatermarkImageSize ImageSize { get; } = WatermarkImageSize.Zoom;
        [UsedImplicitly][Field] public WatermarkTextRotation TextRotation { get; } = WatermarkTextRotation.ForwardDiagonal;
        [UsedImplicitly][Field] public Single ImageTransparency { get; }
        [UsedImplicitly][Field] public FillBase TextFill { get; } = new SolidFill(Color.FromArgb(40,Color.Gray));
        }
    }