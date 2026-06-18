using System;
using System.ComponentModel;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(FastReportFormatConverter))]
    internal abstract class FastReportFormatBase : FastReportObject,IEquatable<FastReportFormatBase>,IEquatable<String>
        {
        #region M:Equals(Object):Boolean
        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns>true if the current object is equal to the other parameter; otherwise, false.</returns>
        public override Boolean Equals(Object other) {
            if (other is String) { return Equals((String)other); }
            return Equals(other as FastReportFormatBase);
            }
        #endregion
        #region M:Equals(FormatBase):Boolean
        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns>true if the current object is equal to the other parameter; otherwise, false.</returns>
        public virtual Boolean Equals(FastReportFormatBase other) {
            if (other == null) { return false; }
            if (ReferenceEquals(this, other)) { return true; }
            return false;
            }
        #endregion
        #region M:Equals(String):Boolean
        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns>true if the current object is equal to the other parameter; otherwise, false.</returns>
        public Boolean Equals(String other) {
            return String.Equals(FastReportFormatConverter.Instance.ConvertToInvariantString(this),other);
            }
        #endregion
        #region M:Serialize(IFastReportSerializer,String,Object)
        public override void Serialize(IFastReportSerializer serializer,String prefix,Object other) {
            if (serializer == null) { throw new ArgumentNullException(nameof(serializer)); }
            serializer.Serialize(this,prefix,other);
            }
        #endregion
        }
    }