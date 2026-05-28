using System.Drawing;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal sealed class PathGradientFill : FillBase
        {
        [UsedImplicitly][Field(Converter=typeof(SqlColorConverter))] public Color CenterColor { get; } = Color.Black;
        [UsedImplicitly][Field(Converter=typeof(SqlColorConverter))] public Color EdgeColor { get; } = Color.White;
        [UsedImplicitly][Field(Converter=typeof(SqlColorConverter))] public PathGradientStyle Style { get; }
        }
    }