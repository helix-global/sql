using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public abstract class SqlMultipartIdentifier : IEnumerable<SqlIdentifier>,IEquatable<SqlMultipartIdentifier>
        {
        public abstract Int32 Count { get; }
        public abstract SqlIdentifier this[Int32 index] { get; }
        public abstract IEnumerable<SqlIdentifier> Children { get; }

        #region M:IEnumerable<SqlIdentifier>.GetEnumerator:IEnumerator<SqlIdentifier>
        public IEnumerator<SqlIdentifier> GetEnumerator()
            {
            return Children.GetEnumerator();
            }
        #endregion
        #region M:IEnumerable.GetEnumerator:IEnumerator
        IEnumerator IEnumerable.GetEnumerator()
            {
            return GetEnumerator();
            }
        #endregion

        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString() {
            var r = new StringBuilder();
            var i = 0;
            foreach (var identifier in Children) {
                if (i > 0) { r.Append("."); }
                r.Append(EscapeSequence.BracketedEscapeSequence.Escape(identifier.Value));
                i++;
                }
            return r.ToString();
            }

        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns>
        /// <see langword="true" /> if the current object is equal to the <paramref name="other" /> parameter; otherwise, <see langword="false" />.</returns>
        public Boolean Equals(SqlMultipartIdentifier other) {
            if (ReferenceEquals(this,other)) { return true; }
            if (ReferenceEquals(null,other)) { return false; }
            return String.Equals(ToString(),other.ToString());
            }

        /// <summary>Determines whether the specified object is equal to the current object.</summary>
        /// <param name="other">The object to compare with the current object.</param>
        /// <returns>
        /// <see langword="true" /> if the specified object  is equal to the current object; otherwise, <see langword="false" />.</returns>
        public override Boolean Equals(Object other) {
            return ReferenceEquals(this, other) || other is SqlMultipartIdentifier o && Equals(o);
            }

        /// <summary>Serves as the default hash function.</summary>
        /// <returns>A hash code for the current object.</returns>
        public override Int32 GetHashCode() {
            return ToString().GetHashCode();
            }
        }
    }