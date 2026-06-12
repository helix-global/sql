using System;
using System.ComponentModel;
using System.Drawing;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal sealed class GlassFill : FillBase
        {
        [UsedImplicitly][Field(Converter=typeof(FastReportColorConverter))][DefaultValue(KnownColor.White)] public Color StartColor { get; } = Color.White;
        [UsedImplicitly][Field(ConverterCulture="en-US")][DefaultValue(0.2f)] public Single Blend { get; } = 0.2f;
        [UsedImplicitly][Field][DefaultValue(true)] public Boolean Hatch { get; } = true;
        }
    }