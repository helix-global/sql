using System;
using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("CurrencyFormat")]
    internal sealed class CurrencyFormat : FormatBase
        {
        [UsedImplicitly][Field][DefaultValue(true)] public Boolean UseLocale { get; } = true;
        [UsedImplicitly][Field][DefaultValue(2)] public Int32 DecimalDigits { get; } = 2;
        [UsedImplicitly][Field] public Int32 NegativePattern { get; }
        [UsedImplicitly][Field] public Int32 PositivePattern { get; }
        [UsedImplicitly][Field] public String CurrencySymbol { get; }
        [UsedImplicitly][Field] public String DecimalSeparator { get; }
        [UsedImplicitly][Field] public String GroupSeparator { get; }
        }
    }