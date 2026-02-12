using System;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public class SqlIdentifier : IEquatable<SqlIdentifier>,IComparable<SqlIdentifier>
        {
        public static readonly SqlIdentifier Null = new NullSqlIdentifier();
        public static readonly SqlIdentifier Missing = new MissingSqlIdentifier();
        public String Value { get; }

        #region ctor
        public SqlIdentifier()
            {
            }
        #endregion
        #region ctor{String}
        public SqlIdentifier(String value) {
            if (String.IsNullOrWhiteSpace(value)) { throw new ArgumentOutOfRangeException(nameof(value));}
            Value = EscapeSequence.UnescapeIdentifier(value);
            if (String.IsNullOrWhiteSpace(value)) { throw new ArgumentOutOfRangeException(nameof(value));}
            }
        #endregion
        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return Value;
            }
        #endregion
        #region M:IsNullOrEmpty(SqlIdentifier):Boolean
        public static Boolean IsNullOrEmpty(SqlIdentifier value) {
            if (value == null) { return true; }
            if (value is NullSqlIdentifier)    { return true; }
            if (value is MissingSqlIdentifier) { return true; }
            return String.IsNullOrWhiteSpace(value.Value);
            }
        #endregion

        private sealed class MissingSqlIdentifier : SqlIdentifier
            {
            public Boolean IsMissing { get { return true; }}
            public override String ToString()
                {
                return "{missing}";
                }
            }

        private sealed class NullSqlIdentifier : SqlIdentifier
            {
            public override String ToString()
                {
                return "{null}";
                }
            }

        #region M:Equals(SqlIdentifier):Boolean
        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns><see langword="true"/> if the current object is equal to the <paramref name="other"/> parameter; otherwise, <see langword="false"/>.</returns>
        public Boolean Equals(SqlIdentifier other) {
            if (ReferenceEquals(null, other)) { return false; }
            if (ReferenceEquals(this, other)) { return true;  }
            return String.Equals(Value,other.Value);
            }
        #endregion
        #region M:Equals(Object):Boolean
        /// <summary>Determines whether the specified object is equal to the current object.</summary>
        /// <param name="other">The object to compare with the current object.</param>
        /// <returns><see langword="true"/> if the specified object  is equal to the current object; otherwise, <see langword="false"/>.</returns>
        public override Boolean Equals(Object other) {
            if (ReferenceEquals(null,other)) { return false; }
            if (ReferenceEquals(this,other)) { return true;  }
            return (other is SqlIdentifier r) && Equals(r);
            }
        #endregion
        #region M:GetHashCode:Int32
        /// <summary>Serves as the default hash function.</summary>
        /// <returns>A hash code for the current object.</returns>
        public override Int32 GetHashCode() {
            return Value != null
                ? Value.GetHashCode()
                : 0;
            }
        #endregion
        #region M:Equals(SqlIdentifier,SqlIdentifier):Boolean
        public static Boolean Equals(SqlIdentifier x,SqlIdentifier y) {
            if (ReferenceEquals(x,y)) { return true; }
            return !ReferenceEquals(x,null)
                ? x.Equals(y)
                : false;
            }
        #endregion
        #region M:CompareTo(SqlIdentifier):Int32
        /// <summary>Compares the current instance with another object of the same type and returns an integer that indicates whether the current instance precedes, follows, or occurs in the same position in the sort order as the other object.</summary>
        /// <param name="other">An object to compare with this instance.</param>
        /// <returns>A value that indicates the relative order of the objects being compared. The return value has these meanings:
        /// Value
        /// Meaning
        /// Less than zero
        /// This instance precedes <paramref name="other"/> in the sort order.
        /// Zero
        /// This instance occurs in the same position in the sort order as <paramref name="other" />.
        /// Greater than zero
        /// This instance follows <paramref name="other"/> in the sort order.</returns>
        public Int32 CompareTo(SqlIdentifier other) {
            if (ReferenceEquals(this,other)) { return 0; }
            if (ReferenceEquals(null,other)) { return 1; }
            return String.Compare(Value,other.Value,StringComparison.Ordinal);
            }
        #endregion
        #region M:Compare(SqlIdentifier,SqlIdentifier):Int32
        public static Int32 Compare(SqlIdentifier x,SqlIdentifier y) {
            if (ReferenceEquals(x,y)) { return 0; }
            return !ReferenceEquals(x,null)
                ? x.CompareTo(y)
                : -1;
            }
        #endregion
        }
    }