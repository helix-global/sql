using System.Drawing;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal sealed class SolidFill : FillBase
        {
        [UsedImplicitly][Field(Converter=typeof(SqlColorConverter))] public Color Color { get; }
        public SolidFill(Color color)
            {
            Color = color;
            }
        }
    }