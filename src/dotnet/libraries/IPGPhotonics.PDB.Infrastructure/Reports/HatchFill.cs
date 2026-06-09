using System.Drawing;
using System.Drawing.Drawing2D;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal sealed class HatchFill : FillBase
        {
        [UsedImplicitly][Field(Converter=typeof(FastReportColorConverter))] public Color BackColor { get; } = Color.White;
        [UsedImplicitly][Field(Converter=typeof(FastReportColorConverter))] public Color ForeColor { get; } = Color.Black;
        [UsedImplicitly][Field(Converter=typeof(SqlEnumConverter<HatchStyle>))] public HatchStyle Style { get; } = HatchStyle.BackwardDiagonal;
        }
    }