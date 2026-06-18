using System;
using System.ComponentModel;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(FastReportFillConverter))]
    internal abstract class FastReportFillBase : FastReportObject,IEquatable<FastReportFillBase>
        {
        #region M:Equals(Object):Boolean
        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns>true if the current object is equal to the other parameter; otherwise, false.</returns>
        public override Boolean Equals(Object other) {
            return Equals(other as FastReportFillBase);
            }
        #endregion
        #region M:Equals(FillBase):Boolean
        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns>true if the current object is equal to the other parameter; otherwise, false.</returns>
        public virtual Boolean Equals(FastReportFillBase other) {
            if (other == null) { return false; }
            if (ReferenceEquals(this, other)) { return true; }
            return false;
            }
        #endregion
        #region M:Equals(FastReportFillBase,FastReportFillBase):Boolean
        public static Boolean Equals(FastReportFillBase x,FastReportFillBase y) {
            if (ReferenceEquals(x,y)) { return true; }
            if ((x == null) || (y == null)) { return false; }
            return x.Equals(y);
            }
        #endregion
        #region M:GetHashCode:Int32
        public override Int32 GetHashCode()
            {
            return 0;
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