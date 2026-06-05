using System;
using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("NumberFormat")]
    internal sealed class NumberFormat : FormatBase
        {
        [UsedImplicitly][Field(Order=1000201)][DefaultValue(true)] public Boolean UseLocale { get; } = true;
        [UsedImplicitly][Field(Order=1000202)] public Int32 DecimalDigits { get; }
        [UsedImplicitly][Field(Order=1000205)] public Int32 NegativePattern { get; }
        [UsedImplicitly][Field(Order=1000203)] public String DecimalSeparator { get; }
        [UsedImplicitly][Field(Order=1000204)] public String GroupSeparator { get; }

        #region M:GetHashCode:Int32
        /// <summary>Calculates a hash code for the current object.</summary>
        /// <returns>Returns a hash code for the current object.</returns>
        public override Int32 GetHashCode() {
            return HashCodeCombiner.GetHashCode(
                UseLocale,DecimalDigits,NegativePattern,
                DecimalSeparator,GroupSeparator);
            }
        #endregion
        }
    }