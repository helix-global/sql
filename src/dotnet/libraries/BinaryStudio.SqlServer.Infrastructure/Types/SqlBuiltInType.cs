using System;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlBuiltInType : SqlType,IEquatable<SqlBuiltInType>
        {
        public override Boolean IsBuiltIn { get { return true; }}
        public override String Name { get; }
        public SqlDataType SqlDataType { get; }
        public SqlBuiltInType(SqlDataType SqlDataType)
            {
            this.SqlDataType = SqlDataType;
            this.Name = (SqlDataType == SqlDataType.Variant)
                ? "sql_variant"
                : $"{SqlDataType.ToString().ToLowerInvariant()}";
            }

        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return $"{Name}";
            }
        #endregion
        #region M:Equals(SqlBuiltInType):Boolean
        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns><see langword="true"/> if the current object is equal to the <paramref name="other"/> parameter; otherwise, <see langword="false"/>.</returns>
        public Boolean Equals(SqlBuiltInType other) {
            if (ReferenceEquals(null, other)) { return false; }
            if (ReferenceEquals(this, other)) { return true;  }
            return SqlDataType == other.SqlDataType;
            }
        #endregion
        #region M:Equals(Object):Boolean
        /// <summary>Determines whether the specified object is equal to the current object.</summary>
        /// <param name="other">The object to compare with the current object.</param>
        /// <returns><see langword="true"/> if the specified object  is equal to the current object; otherwise, <see langword="false"/>.</returns>
        public override Boolean Equals(Object other) {
            return ReferenceEquals(this,other) ||
                (other is SqlBuiltInType type) &&
                Equals(type);
            }
        #endregion
        #region M:GetHashCode:Int32
        /// <summary>Serves as the default hash function.</summary>
        /// <returns>A hash code for the current object.</returns>
        public override Int32 GetHashCode() {
            return (Int32)SqlDataType;
            }
        #endregion
        }
    }