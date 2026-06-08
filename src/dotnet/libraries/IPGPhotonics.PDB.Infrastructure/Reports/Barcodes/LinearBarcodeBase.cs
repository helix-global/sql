using System;
using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class LinearBarcodeBase : BarcodeBase
        {
        [UsedImplicitly][Field(Order=1000302)][DefaultValue(true)] public Boolean CalcCheckSum { get; } = true;
        [UsedImplicitly][Field(Order=1000301,ConverterCulture="en-US")][DefaultValue(2f)] public Single WideBarRatio { get; } = 2f;
        }
    }