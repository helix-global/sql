using System;
using System.ComponentModel;
using System.Xml;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(FillConverter))]
    internal abstract class FillBase : FastReportObject,IEquatable<FillBase>
        {
        #region M:Serialize(XmlWriter,String,Object)
        public override void Serialize(XmlWriter writer,String prefix,Object other) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            if (other != null) {
                if (other.GetType() != GetType()) {
                    writer.WriteAttributeString(prefix,FillConverter.Instance.ConvertToInvariantString(this));
                    }
                }
            else
                {
                writer.WriteAttributeString(prefix,FillConverter.Instance.ConvertToInvariantString(this));
                }
            SerializeAttributes(writer,prefix);
            }
        #endregion
        #region M:Equals(Object):Boolean
        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns>true if the current object is equal to the other parameter; otherwise, false.</returns>
        public override Boolean Equals(Object other) {
            return Equals(other as FillBase);
            }
        #endregion
        #region M:Equals(FillBase):Boolean
        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns>true if the current object is equal to the other parameter; otherwise, false.</returns>
        public virtual Boolean Equals(FillBase other) {
            if (other == null) { return false; }
            if (ReferenceEquals(this, other)) { return true; }
            return false;
            }
        #endregion
        #region M:GetHashCode:Int32
        public override Int32 GetHashCode()
            {
            return 0;
            }
        #endregion
        }
    }