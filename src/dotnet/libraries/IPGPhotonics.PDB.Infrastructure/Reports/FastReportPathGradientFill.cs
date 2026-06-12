using System.ComponentModel;
using System.Drawing;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal sealed class FastReportPathGradientFill : FastReportFillBase
        {
        [UsedImplicitly][Field(Converter=typeof(FastReportColorConverter))][DefaultValue(KnownColor.Black)] public Color CenterColor { get; } = Color.Black;
        [UsedImplicitly][Field(Converter=typeof(FastReportColorConverter))][DefaultValue(KnownColor.White)] public Color EdgeColor { get; } = Color.White;
        [UsedImplicitly][Field(Converter=typeof(FastReportColorConverter))] public PathGradientStyle Style { get; }
        }
    }