using System;
using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("NumericUpDownControl")]
    internal sealed class NumericUpDownControl : DataFilterBaseControl
        {
        [UsedImplicitly][Field(Order=1000602)] public Boolean Hexadecimal { get; }
        [UsedImplicitly][Field(Order=1000606)] public Boolean ThousandsSeparator { get; }
        [UsedImplicitly][Field(Order=1000601)] public Int32 DecimalPlaces { get; }
        [UsedImplicitly][Field(Order=1000603,ConverterCulture="en-US")][DefaultValue(1f)] public Single Increment { get; } = 1f;
        [UsedImplicitly][Field(Order=1000604,ConverterCulture="en-US")][DefaultValue(100f)] public Single Maximum { get; } = 100f;
        [UsedImplicitly][Field(Order=1000605,ConverterCulture="en-US")] public Single Minimum { get; }
        [UsedImplicitly][Field(Order=1000607,ConverterCulture="en-US")] public Single Value { get; }
        [UsedImplicitly][Field(Order=1000608,ConverterCulture="en-US")] public String ValueChangedEvent { get; }
        }
    }