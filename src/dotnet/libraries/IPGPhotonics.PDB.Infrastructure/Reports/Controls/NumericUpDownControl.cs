using System;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("NumericUpDownControl")]
    internal sealed class NumericUpDownControl : DataFilterBaseControl
        {
        [UsedImplicitly][Field] public Boolean Hexadecimal { get; }
        [UsedImplicitly][Field] public Boolean ThousandsSeparator { get; }
        [UsedImplicitly][Field] public Int32 DecimalPlaces { get; }
        [UsedImplicitly][Field] public Single Increment { get; } = 1f;
        [UsedImplicitly][Field] public Single Maximum { get; } = 100f;
        [UsedImplicitly][Field] public Single Minimum { get; }
        [UsedImplicitly][Field] public Single Value { get; }
        [UsedImplicitly][Field] public String ValueChangedEvent { get; }
        }
    }