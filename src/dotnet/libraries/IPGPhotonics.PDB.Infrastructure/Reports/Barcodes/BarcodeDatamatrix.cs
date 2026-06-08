using System;
using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal sealed class BarcodeDatamatrix : Barcode2DBase
        {
        [UsedImplicitly][Field(Order=1000301)] public DatamatrixSymbolSize SymbolSize { get; }
        [UsedImplicitly][Field(Order=1000302)] public DatamatrixEncoding Encoding { get; }
        [UsedImplicitly][Field(Order=1000303)] public Int32 CodePage { get; }
        [UsedImplicitly][Field(Order=1000304)][DefaultValue(0)] public Int32 PixelSize { get; } = 3;
        }
    }