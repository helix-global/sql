using System;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class LinearBarcodeBase : BarcodeBase
        {
        [UsedImplicitly][Field] public Boolean CalcCheckSum { get; } = true;
        [UsedImplicitly][Field(ConverterCulture="en-US")] public Single WideBarRatio { get; } = 2f;
        }
    }