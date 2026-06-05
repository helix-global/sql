using System;
using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("PercentFormat")]
    internal sealed class PercentFormat : FormatBase
        {
        [UsedImplicitly][Field(Order=1000201)][DefaultValue(true)] public Boolean UseLocale { get; } = true;
        [UsedImplicitly][Field(Order=1000202)][DefaultValue(2)] public Int32 DecimalDigits { get; } = 2;
        [UsedImplicitly][Field(Order=1000203)] public String DecimalSeparator { get; }
        [UsedImplicitly][Field(Order=1000204)] public String GroupSeparator { get; }
        [UsedImplicitly][Field(Order=1000205)] public String PercentSymbol { get; }
        [UsedImplicitly][Field(Order=1000207)] public Int32 NegativePattern { get; }
        [UsedImplicitly][Field(Order=1000206)] public Int32 PositivePattern { get; }

        #region M:GetHashCode:Int32
        /// <summary>Calculates a hash code for the current object.</summary>
        /// <returns>Returns a hash code for the current object.</returns>
        public override Int32 GetHashCode() {
            return HashCodeCombiner.GetHashCode(
                UseLocale,DecimalDigits,NegativePattern,
                DecimalSeparator,GroupSeparator,PositivePattern,
                PercentSymbol);
            }
        #endregion
        }
    }