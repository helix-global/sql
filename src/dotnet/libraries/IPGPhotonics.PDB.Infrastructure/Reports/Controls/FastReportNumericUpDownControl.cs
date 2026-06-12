using System;
using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("NumericUpDownControl")]
    internal sealed class FastReportNumericUpDownControl : FastReportDataFilterBaseControl
        {
        [UsedImplicitly][Field(Order=1000602)] public Boolean Hexadecimal { get; }
        [UsedImplicitly][Field(Order=1000606)] public Boolean ThousandsSeparator { get; }
        [UsedImplicitly][Field(Order=1000601)] public Int32 DecimalPlaces { get; }
        [UsedImplicitly][Field(Order=1000603,ConverterCulture="en-US")][DefaultValue(1.0)] public Double Increment { get; } = 1.0;
        [UsedImplicitly][Field(Order=1000604,ConverterCulture="en-US")][DefaultValue(100.0)] public Double Maximum { get; } = 100.0;
        [UsedImplicitly][Field(Order=1000605,ConverterCulture="en-US")] public Double Minimum { get; }
        [UsedImplicitly][Field(Order=1000607,ConverterCulture="en-US")] public Double Value { get; }
        [UsedImplicitly][Field(Order=1000608,ConverterCulture="en-US")] public String ValueChangedEvent { get; }
        }
    }