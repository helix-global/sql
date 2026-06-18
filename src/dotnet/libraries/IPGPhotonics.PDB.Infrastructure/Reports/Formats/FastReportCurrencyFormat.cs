using System;
using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("CurrencyFormat")]
    internal sealed class FastReportCurrencyFormat : FastReportFormatBase,IEquatable<FastReportCurrencyFormat>
        {
        [UsedImplicitly][Field(Order=1000201)][DefaultValue(true)] public Boolean UseLocale { get; } = true;
        [UsedImplicitly][Field(Order=1000202)][DefaultValue(2)] public Int32 DecimalDigits { get; } = 2;
        [UsedImplicitly][Field(Order=1000207)] public Int32 NegativePattern { get; }
        [UsedImplicitly][Field(Order=1000206)] public Int32 PositivePattern { get; }
        [UsedImplicitly][Field(Order=1000205)] public String CurrencySymbol { get; }
        [UsedImplicitly][Field(Order=1000203)] public String DecimalSeparator { get; }
        [UsedImplicitly][Field(Order=1000204)] public String GroupSeparator { get; }

        #region M:Serialize(IFastReportSerializer,String,Object)
        public override void Serialize(IFastReportSerializer serializer,String prefix,Object other) {
            if (serializer == null) { throw new ArgumentNullException(nameof(serializer)); }
            serializer.Serialize(this,prefix,other);
            }
        #endregion
        #region M:GetHashCode:Int32
        /// <summary>Calculates a hash code for the current object.</summary>
        /// <returns>Returns a hash code for the current object.</returns>
        public override Int32 GetHashCode() {
            return HashCodeCombiner.GetHashCode(
                UseLocale,DecimalDigits,
                NegativePattern,PositivePattern,
                DecimalSeparator,GroupSeparator,
                CurrencySymbol);
            }
        #endregion
        #region M:Equals(CurrencyFormat):Boolean
        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns>true if the current object is equal to the other parameter; otherwise, false.</returns>
        public Boolean Equals(FastReportCurrencyFormat other) {
            if (other == null) { return false; }
            if (ReferenceEquals(this, other)) { return true; }
            return (UseLocale==other.UseLocale)
                && (DecimalDigits==other.DecimalDigits)
                && (NegativePattern==other.NegativePattern)
                && (PositivePattern==other.PositivePattern)
                && String.Equals(CurrencySymbol,other.CurrencySymbol)
                && String.Equals(DecimalSeparator,other.DecimalSeparator)
                && String.Equals(GroupSeparator,other.GroupSeparator);
            }
        #endregion
        #region M:Equals(FormatBase):Boolean
        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns>true if the current object is equal to the other parameter; otherwise, false.</returns>
        public override Boolean Equals(FastReportFormatBase other) {
            if (other == null) { return false; }
            if (ReferenceEquals(this, other)) { return true; }
            return Equals(other as FastReportCurrencyFormat);
            }
        #endregion
        }
    }