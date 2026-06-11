using System;
using System.ComponentModel;
using System.Xml;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [TypeConverter(typeof(FormatConverter))]
    internal abstract class FormatBase : FastReportObject,IEquatable<FormatBase>,IEquatable<String>
        {
        #region M:Serialize(XmlWriter,String,Object)
        public override void Serialize(XmlWriter writer,String prefix,Object other) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            writer.WriteAttributeString(prefix,FormatConverter.Instance.ConvertToInvariantString(this));
            SerializeAttributes(writer,prefix);
            }
        #endregion
        #region M:SerializeFull(XmlWriter,String)
        public virtual void SerializeFull(XmlWriter writer,String prefix) {
            base.Serialize(writer,prefix,null);
            }
        #endregion
        #region M:Equals(Object):Boolean
        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns>true if the current object is equal to the other parameter; otherwise, false.</returns>
        public override Boolean Equals(Object other) {
            if (other is String) { return Equals((String)other); }
            return Equals(other as FormatBase);
            }
        #endregion
        #region M:Equals(FormatBase):Boolean
        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns>true if the current object is equal to the other parameter; otherwise, false.</returns>
        public virtual Boolean Equals(FormatBase other) {
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
            return String.Equals(FormatConverter.Instance.ConvertToInvariantString(this),other);
            }
        #endregion
        }
    }