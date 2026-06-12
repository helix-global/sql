using System;
using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class FastReportLinearBarcodeBase : FastReportBarcodeBase,IEquatable<FastReportLinearBarcodeBase>
        {
        [UsedImplicitly][Field(Order=1000302)][DefaultValue(true)] public Boolean CalcCheckSum { get; } = true;
        [UsedImplicitly][Field(Order=1000301,ConverterCulture="en-US")][DefaultValue(2f)] public Single WideBarRatio { get; } = 2f;

        #region M:Equals(LinearBarcodeBase):Boolean
        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns>true if the current object is equal to the other parameter; otherwise, false.</returns>
        public virtual Boolean Equals(FastReportLinearBarcodeBase other) {
            if (other == null) { return false; }
            if (ReferenceEquals(this,other)) { return true; }
            return (CalcCheckSum == other.CalcCheckSum)
                && (WideBarRatio == other.WideBarRatio);
            }
        #endregion
        #region M:Equals(BarcodeBase):Boolean
        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns>true if the current object is equal to the other parameter; otherwise, false.</returns>
        public override Boolean Equals(FastReportBarcodeBase other) {
            if (other == null) { return false; }
            if (ReferenceEquals(this, other)) { return true; }
            return Equals(other as FastReportLinearBarcodeBase);
            }
        #endregion
        #region M:ToString:String
        public override String ToString()
            {
            return $"{BarcodeConverter.Instance.ConvertToInvariantString(this)}:CalcCheckSum={CalcCheckSum};WideBarRatio={WideBarRatio}";
            }
        #endregion
        }
    }