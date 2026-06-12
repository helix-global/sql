using System;
using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal sealed class FastReportBarcode128 : FastReportLinearBarcodeBase,IEquatable<FastReportBarcode128>
        {
        [UsedImplicitly][Field(Order=1000401)][DefaultValue(false)] public Boolean AutoEncode { get; }

        #region M:ToString:String
        public override String ToString()
            {
            return $"{base.ToString()};AutoEncode={AutoEncode}";
            }
        #endregion
        #region M:Equals(Barcode128):Boolean
        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns>true if the current object is equal to the other parameter; otherwise, false.</returns>
        public Boolean Equals(FastReportBarcode128 other) {
            if (other == null) { return false; }
            if (ReferenceEquals(this,other)) { return true; }
            return (CalcCheckSum == other.CalcCheckSum)
                && (WideBarRatio == other.WideBarRatio)
                && (AutoEncode == other.AutoEncode);
            }
        #endregion
        #region M:Equals(LinearBarcodeBase):Boolean
        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns>true if the current object is equal to the other parameter; otherwise, false.</returns>
        public override Boolean Equals(FastReportLinearBarcodeBase other) {
            if (other == null) { return false; }
            if (ReferenceEquals(this,other)) { return true; }
            return Equals(other as FastReportBarcode128);
            }
        #endregion
        }
    }