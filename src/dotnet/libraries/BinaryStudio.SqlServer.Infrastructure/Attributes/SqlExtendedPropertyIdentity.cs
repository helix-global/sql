using System;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public class SqlExtendedPropertyIdentity : IEquatable<SqlExtendedPropertyIdentity>,IComparable<SqlExtendedPropertyIdentity>
        {
        public SqlObjectClass ObjectClass { get; }
        public SqlObjectIdentifier ObjectIdentifier { get; }
        public String PropertyName { get; }

        #region ctor{SqlObjectClass,SqlObjectIdentifier}
        public SqlExtendedPropertyIdentity(SqlObjectClass ObjectClass,SqlObjectIdentifier ObjectIdentifier,String PropertyName)
            {
            this.ObjectClass = ObjectClass;
            this.ObjectIdentifier = ObjectIdentifier;
            this.PropertyName = PropertyName;
            }
        #endregion

        #region M:CompareTo(SqlExtendedPropertyIdentity):Int32
        /// <summary>Compares the current instance with another object of the same type and returns an integer that indicates whether the current instance precedes, follows, or occurs in the same position in the sort order as the other object.</summary>
        /// <param name="other">An object to compare with this instance.</param>
        /// <returns>A value that indicates the relative order of the objects being compared. The return value has these meanings:
        /// Value
        /// Meaning
        /// Less than zero
        /// This instance precedes <paramref name="other"/> in the sort order.
        /// Zero
        /// This instance occurs in the same position in the sort order as <paramref name="other"/>.
        /// Greater than zero
        /// This instance follows <paramref name="other" /> in the sort order.</returns>
        public Int32 CompareTo(SqlExtendedPropertyIdentity other) {
            if (ReferenceEquals(other,null)) { return +1; }
            if (ReferenceEquals(other,this)) { return  0; }
            var r = ObjectClass.CompareTo(other.ObjectClass);
            if (r != 0) { return r; }
            r = ObjectIdentifier.CompareTo(other.ObjectIdentifier);
            return (r != 0)
                ? r
                : String.Compare(PropertyName,other.PropertyName,StringComparison.Ordinal);
            }
        #endregion
        #region M:Equals(SqlExtendedPropertyIdentity):Boolean
        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns><see langword="true"/> if the current object is equal to the <paramref name="other"/> parameter; otherwise, <see langword="false"/>.</returns>
        public Boolean Equals(SqlExtendedPropertyIdentity other) {
            if (ReferenceEquals(null,other)) { return false; }
            if (ReferenceEquals(this,other)) { return true;  }
            return (ObjectClass == other.ObjectClass)
                && Equals(ObjectIdentifier,other.ObjectIdentifier)
                && String.Equals(PropertyName,other.PropertyName);
            }
        #endregion
        #region M:Equals(Object):Boolean
        /// <summary>Determines whether the specified object is equal to the current object.</summary>
        /// <param name="other">The object to compare with the current object.</param>
        /// <returns><see langword="true" /> if the specified object  is equal to the current object; otherwise, <see langword="false"/>.</returns>
        public override Boolean Equals(Object other) {
            if (ReferenceEquals(null,other)) { return false; }
            if (ReferenceEquals(this,other)) { return true;  }
            return (other is SqlExtendedPropertyIdentity o) && Equals(o);
            }
        #endregion
        #region M:GetHashCode:Int32
        /// <summary>Serves as the default hash function.</summary>
        /// <returns>A hash code for the current object.</returns>
        public override Int32 GetHashCode()
            {
            return HashCodeCombiner.GetHashCode(ObjectClass,ObjectIdentifier,PropertyName);
            }
        #endregion
        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return $"[{ObjectClass}].{ObjectIdentifier}.[{PropertyName}]";
            }
        #endregion
        #region operator ==(SqlExtendedPropertyIdentity,SqlExtendedPropertyIdentity):Boolean
        public static Boolean operator ==(SqlExtendedPropertyIdentity x,SqlExtendedPropertyIdentity y)
            {
            return Equals(x, y);
            }
        #endregion
        #region operator !=(SqlExtendedPropertyIdentity,SqlExtendedPropertyIdentity):Boolean
        public static Boolean operator !=(SqlExtendedPropertyIdentity x,SqlExtendedPropertyIdentity y)
            {
            return !Equals(x, y);
            }
        #endregion
        }
    }