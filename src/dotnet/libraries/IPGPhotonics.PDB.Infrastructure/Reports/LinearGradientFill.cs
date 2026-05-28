using System;
using System.Drawing;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal sealed class LinearGradientFill : FillBase
        {
        [UsedImplicitly][Field(Converter=typeof(SqlColorConverter))] public Color StartColor { get; } = Color.Black;
        [UsedImplicitly][Field(Converter=typeof(SqlColorConverter))] public Color EndColor { get; } = Color.White;
        [UsedImplicitly][Field] public Int32 Angle { get; }
        [UsedImplicitly][Field] public Single Contrast { get; } = 100f;
        [UsedImplicitly][Field] public Single Focus { get; } = 100f;
        }
    }