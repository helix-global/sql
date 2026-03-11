using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.IO;
using System.Linq;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    /// <summary>
    /// [ObjectName]
    /// [SchemaName].[ObjectName]
    /// [DatabaseName].[SchemaName].[ObjectName]
    /// </summary>
    [TypeConverter(typeof(SqlObjectIdentifierConverter))]
    public abstract class SqlObjectIdentifier : SqlMultipartIdentifier,IEquatable<SqlObjectIdentifier>,IComparable<SqlObjectIdentifier>
        {
        public abstract Boolean IsMultiPartName { get; }
        public abstract SqlIdentifier ServerName { get; }
        public abstract SqlIdentifier DatabaseName { get; }
        public abstract SqlIdentifier SchemaName { get; }
        public abstract SqlIdentifier ObjectName { get; }

        #region M:Create(SqlIdentifier):SqlObjectIdentifier
        private static SqlObjectIdentifier Create(SqlIdentifier ObjectName) {
            return new OnePartObjectIdentifier(ObjectName);
            }
        #endregion
        #region M:Create(SqlIdentifier,SqlIdentifier):SqlObjectIdentifier
        private static SqlObjectIdentifier Create(SqlIdentifier SchemaName,SqlIdentifier ObjectName) {
            return new TwoPartObjectIdentifier(SchemaName,ObjectName);
            }
        #endregion
        #region M:Create(SqlIdentifier,SqlIdentifier,SqlIdentifier):SqlObjectIdentifier
        private static SqlObjectIdentifier Create(SqlIdentifier DatabaseName,SqlIdentifier SchemaName,SqlIdentifier ObjectName) {
            return new ThreePartObjectIdentifier(DatabaseName,SchemaName,ObjectName);
            }
        #endregion
        #region M:Create(SqlIdentifier,SqlIdentifier,SqlIdentifier,SqlIdentifier):SqlObjectIdentifier
        private static SqlObjectIdentifier Create(SqlIdentifier ServerName,SqlIdentifier DatabaseName,SqlIdentifier SchemaName,SqlIdentifier ObjectName) {
            return new FourPartObjectIdentifier(ServerName,DatabaseName,SchemaName,ObjectName);
            }
        #endregion
        #region M:Create(IList<SqlIdentifier>):SqlObjectIdentifier
        private static SqlObjectIdentifier Create(IList<SqlIdentifier> identifiers) {
            switch (identifiers.Count) {
                case 1: return Create(identifiers[0]);
                case 2: return Create(identifiers[0],identifiers[1]);
                case 3: return Create(identifiers[0],identifiers[1],identifiers[2]);
                case 4: return Create(identifiers[0],identifiers[1],identifiers[2],identifiers[3]);
                default: return new MultiPartObjectIdentifier(identifiers);
                }
            }
        #endregion
        #region M:Create(IEnumerable<SqlIdentifier>):SqlObjectIdentifier
        public static SqlObjectIdentifier Create(IEnumerable<SqlIdentifier> identifiers) {
            return Create(identifiers.ToArray());
            }
        #endregion
        #region M:Create({params}String[]):SqlObjectIdentifier
        public static SqlObjectIdentifier Create(params String[] args) {
            switch (args.Length) {
                case 1: return Create(new SqlIdentifier(args[0]));
                case 2: return Create(new SqlIdentifier(args[0]),new SqlIdentifier(args[1]));
                case 3: return Create(new SqlIdentifier(args[0]),new SqlIdentifier(args[1]),new SqlIdentifier(args[2]));
                case 4: return Create(new SqlIdentifier(args[0]),new SqlIdentifier(args[1]),new SqlIdentifier(args[2]),new SqlIdentifier(args[4]));
                default: return new MultiPartObjectIdentifier(args.Select(i => new SqlIdentifier(i)));
                }
            }
        #endregion
        #region M:Parse(String):SqlObjectIdentifier
        public static SqlObjectIdentifier Parse(String value) {
            if (String.IsNullOrWhiteSpace(value)) { return null; }
            var escape = EscapeSequence.IdentifyEscapeSequence(value);
            return (escape != null)
                ? Parse(value,escape)
                : Create(new SqlIdentifier(value));
            }
        #endregion
        #region M:Parse(String,EscapeSequence):SqlObjectIdentifier
        private static SqlObjectIdentifier Parse(String value,EscapeSequence escape) {
            if (escape == null) { throw new ArgumentNullException(nameof(escape)); }
            if (String.IsNullOrWhiteSpace(value)) { throw new ArgumentOutOfRangeException(nameof(value)); }
            using (var reader = new StringReader(value)) {
                return Parse(reader,escape);
                }
            }
        #endregion
        #region M:Parse(TextReader,EscapeSequence):SqlObjectIdentifier
        private static SqlObjectIdentifier Parse(TextReader reader,EscapeSequence escape) {
            if (escape == null) { throw new ArgumentNullException(nameof(escape)); }
            if (reader == null) { throw new ArgumentNullException(nameof(reader)); }
            var identifiers = new List<SqlIdentifier>();
            SqlIdentifier identifier;
            while ((identifier = ReadNextIdentifier(reader,escape)) != null)
                {
                identifiers.Add(identifier);
                }
            return Create(identifiers);
            }
        #region M:ReadNextIdentifier(TextReader,EscapeSequence):SqlIdentifier
        private static SqlIdentifier ReadNextIdentifier(TextReader reader,EscapeSequence escape) {
            if (escape == null) { throw new ArgumentNullException(nameof(escape)); }
            if (reader == null) { throw new ArgumentNullException(nameof(reader)); }
            var c = reader.Peek();
            if (c == '.') {
                reader.Read();
                return ReadNextIdentifier(reader,escape);
                }
            if (c == escape.StartChar) {
                var r = new StringBuilder();
                r.Append((char)reader.Read());
                c = reader.Peek();
                while ((c != escape.EndChar) && (c != -1)) {
                    reader.Read();
                    r.Append((char)c);
                    c = reader.Peek();
                    }
                if (c != -1)
                    {
                    r.Append((char)reader.Read());
                    }
                return new SqlIdentifier(r.ToString());
                }
            return null;
            }
        #endregion

        #endregion
        #region M:IsNullOrEmpty(SqlObjectIdentifier):Boolean
        public static Boolean IsNullOrEmpty(SqlObjectIdentifier value) {
            if (ReferenceEquals(value,null)) { return true; }
            foreach (var identifier in value.Children) {
                if (!IsNullOrEmpty(identifier)) {
                    return false;
                    }
                }
            return true;
            }
        #endregion
        #region M:IsNullOrEmpty(SqlIdentifier):Boolean
        public static Boolean IsNullOrEmpty(SqlIdentifier value) {
            return SqlIdentifier.IsNullOrEmpty(value);
            }
        #endregion

        public static SqlObjectIdentifier operator +(SqlObjectIdentifier x,String y)
            {
            return x + Parse(y);
            }

        public static SqlObjectIdentifier operator +(SqlObjectIdentifier x,SqlObjectIdentifier y) {
            var r = new List<SqlIdentifier>();
            r.AddRange(x.Children);
            r.AddRange(y.Children);
            return Create(r);
            }

        public static SqlObjectIdentifier operator +(SqlObjectIdentifier x,SqlIdentifier y) {
            var r = new List<SqlIdentifier>();
            r.AddRange(x.Children);
            r.Add(y);
            return Create(r);
            }

        public static Boolean operator ==(SqlObjectIdentifier x,SqlObjectIdentifier y)
            {
            return Equals(x,y);
            }

        public static Boolean operator !=(SqlObjectIdentifier x,SqlObjectIdentifier y)
            {
            return !Equals(x,y);
            }

        public static Boolean operator ==(SqlObjectIdentifier x,String y)
            {
            return Equals(x,Parse(y));
            }

        public static Boolean operator !=(SqlObjectIdentifier x,String y)
            {
            return !Equals(x,Parse(y));
            }

        private sealed class OnePartObjectIdentifier : SqlObjectIdentifier
            {
            public override Int32 Count { get{ return 1; }}
            public override Boolean IsMultiPartName { get { return false; }}
            public override SqlIdentifier ServerName   { get { return SqlIdentifier.Null; }}
            public override SqlIdentifier DatabaseName { get { return SqlIdentifier.Null; }}
            public override SqlIdentifier SchemaName   { get { return SqlIdentifier.Null; }}
            public override SqlIdentifier ObjectName   { get; }

            public override IEnumerable<SqlIdentifier> Children { get {
                yield return ObjectName;
                }}

            public override SqlIdentifier this[Int32 index] { get {
                switch (index) {
                    case 0: return ObjectName;
                    default: throw new IndexOutOfRangeException();
                    }
                }}

            public OnePartObjectIdentifier(SqlIdentifier ObjectName)
                {
                this.ObjectName = ObjectName;
                }

            #region M:GetHashCode:Int32
            /// <summary>Serves as the default hash function.</summary>
            /// <returns>A hash code for the current object.</returns>
            public override Int32 GetHashCode()
                {
                return HashCodeCombiner.GetHashCode(ObjectName);
                }
            #endregion
            #region M:Equals(SqlObjectIdentifier):Boolean
            /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
            /// <param name="other">An object to compare with this object.</param>
            /// <returns><see langword="true"/> if the current object is equal to the <paramref name="other"/> parameter; otherwise, <see langword="false"/>.</returns>
            public override Boolean Equals(SqlObjectIdentifier other) {
                if (ReferenceEquals(null,other)) { return false; }
                if (ReferenceEquals(this,other)) { return true;  }
                return (Count==other.Count)
                    && SqlIdentifier.Equals(ObjectName,other.ObjectName);
                }
            #endregion
            }

        private sealed class TwoPartObjectIdentifier : SqlObjectIdentifier
            {
            public override Int32 Count { get{ return 2; }}
            public override Boolean IsMultiPartName { get { return true; }}
            public override SqlIdentifier ServerName   { get { return SqlIdentifier.Null; }}
            public override SqlIdentifier DatabaseName { get { return SqlIdentifier.Null; }}
            public override SqlIdentifier SchemaName   { get; }
            public override SqlIdentifier ObjectName   { get; }

            public override IEnumerable<SqlIdentifier> Children { get {
                yield return SchemaName;
                yield return ObjectName;
                }}

            public override SqlIdentifier this[Int32 index] { get {
                switch (index) {
                    case 0: return SchemaName;
                    case 1: return ObjectName;
                    default: throw new IndexOutOfRangeException();
                    }
                }}

            public TwoPartObjectIdentifier(SqlIdentifier SchemaName,SqlIdentifier ObjectName)
                {
                this.SchemaName = SchemaName;
                this.ObjectName = ObjectName;
                }

            #region M:GetHashCode:Int32
            /// <summary>Serves as the default hash function.</summary>
            /// <returns>A hash code for the current object.</returns>
            public override Int32 GetHashCode()
                {
                return HashCodeCombiner.GetHashCode(SchemaName,ObjectName);
                }
            #endregion
            #region M:Equals(SqlObjectIdentifier):Boolean
            /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
            /// <param name="other">An object to compare with this object.</param>
            /// <returns><see langword="true"/> if the current object is equal to the <paramref name="other"/> parameter; otherwise, <see langword="false"/>.</returns>
            public override Boolean Equals(SqlObjectIdentifier other) {
                if (ReferenceEquals(null,other)) { return false; }
                if (ReferenceEquals(this,other)) { return true;  }
                return (Count==other.Count)
                    && SqlIdentifier.Equals(SchemaName,other.SchemaName)
                    && SqlIdentifier.Equals(ObjectName,other.ObjectName);
                }
            #endregion
            }

        private sealed class ThreePartObjectIdentifier : SqlObjectIdentifier
            {
            public override Int32 Count { get{ return 3; }}
            public override Boolean IsMultiPartName { get { return true; }}
            public override SqlIdentifier ServerName   { get { return SqlIdentifier.Null; }}
            public override SqlIdentifier DatabaseName { get; }
            public override SqlIdentifier SchemaName   { get; }
            public override SqlIdentifier ObjectName   { get; }

            public override IEnumerable<SqlIdentifier> Children { get {
                yield return DatabaseName;
                yield return SchemaName;
                yield return ObjectName;
                }}

            public override SqlIdentifier this[Int32 index] { get {
                switch (index) {
                    case 0: return DatabaseName;
                    case 1: return SchemaName;
                    case 2: return ObjectName;
                    default: throw new IndexOutOfRangeException();
                    }
                }}

            public ThreePartObjectIdentifier(SqlIdentifier DatabaseName,SqlIdentifier SchemaName,SqlIdentifier ObjectName)
                {
                this.DatabaseName = DatabaseName;
                this.SchemaName = SchemaName;
                this.ObjectName = ObjectName;
                }

            #region M:GetHashCode:Int32
            /// <summary>Serves as the default hash function.</summary>
            /// <returns>A hash code for the current object.</returns>
            public override Int32 GetHashCode()
                {
                return HashCodeCombiner.GetHashCode(DatabaseName,SchemaName,ObjectName);
                }
            #endregion
            #region M:Equals(SqlObjectIdentifier):Boolean
            /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
            /// <param name="other">An object to compare with this object.</param>
            /// <returns><see langword="true"/> if the current object is equal to the <paramref name="other"/> parameter; otherwise, <see langword="false"/>.</returns>
            public override Boolean Equals(SqlObjectIdentifier other) {
                if (ReferenceEquals(null,other)) { return false; }
                if (ReferenceEquals(this,other)) { return true;  }
                return (Count==other.Count)
                    && SqlIdentifier.Equals(DatabaseName,other.DatabaseName)
                    && SqlIdentifier.Equals(SchemaName,other.SchemaName)
                    && SqlIdentifier.Equals(ObjectName,other.ObjectName);
                }
            #endregion
            }

        private sealed class FourPartObjectIdentifier : SqlObjectIdentifier
            {
            public override Int32 Count { get{ return 4; }}
            public override Boolean IsMultiPartName { get { return true; }}
            public override SqlIdentifier ServerName   { get; }
            public override SqlIdentifier DatabaseName { get; }
            public override SqlIdentifier SchemaName   { get; }
            public override SqlIdentifier ObjectName   { get; }

            public override IEnumerable<SqlIdentifier> Children { get {
                yield return ServerName;
                yield return DatabaseName;
                yield return SchemaName;
                yield return ObjectName;
                }}

            public override SqlIdentifier this[Int32 index] { get {
                switch (index) {
                    case 0: return ServerName;
                    case 1: return DatabaseName;
                    case 2: return SchemaName;
                    case 3: return ObjectName;
                    default: throw new IndexOutOfRangeException();
                    }
                }}

            public FourPartObjectIdentifier(SqlIdentifier ServerName,SqlIdentifier DatabaseName,SqlIdentifier SchemaName,SqlIdentifier ObjectName)
                {
                this.ServerName = ServerName;
                this.DatabaseName = DatabaseName;
                this.SchemaName = SchemaName;
                this.ObjectName = ObjectName;
                }

            #region M:GetHashCode:Int32
            /// <summary>Serves as the default hash function.</summary>
            /// <returns>A hash code for the current object.</returns>
            public override Int32 GetHashCode()
                {
                return HashCodeCombiner.GetHashCode(ServerName,DatabaseName,SchemaName,ObjectName);
                }
            #endregion
            #region M:Equals(SqlObjectIdentifier):Boolean
            /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
            /// <param name="other">An object to compare with this object.</param>
            /// <returns><see langword="true"/> if the current object is equal to the <paramref name="other"/> parameter; otherwise, <see langword="false"/>.</returns>
            public override Boolean Equals(SqlObjectIdentifier other) {
                if (ReferenceEquals(null,other)) { return false; }
                if (ReferenceEquals(this,other)) { return true;  }
                return (Count==other.Count)
                    && SqlIdentifier.Equals(ServerName,other.ServerName)
                    && SqlIdentifier.Equals(DatabaseName,other.DatabaseName)
                    && SqlIdentifier.Equals(SchemaName,other.SchemaName)
                    && SqlIdentifier.Equals(ObjectName,other.ObjectName);
                }
            #endregion
            }

        private sealed class MultiPartObjectIdentifier : SqlObjectIdentifier
            {
            private readonly SqlIdentifier[] identifiers;
            public MultiPartObjectIdentifier(IEnumerable<SqlIdentifier> Identifiers)
                {
                identifiers = Identifiers.ToArray();
                }

            public override Boolean IsMultiPartName { get { return true; }}
            public override Int32 Count { get{ return identifiers.Length; }}
            public override IEnumerable<SqlIdentifier> Children { get { return identifiers; }}
            public override SqlIdentifier ServerName   { get { return identifiers[identifiers.Length-4]; }}
            public override SqlIdentifier DatabaseName { get { return identifiers[identifiers.Length-3]; }}
            public override SqlIdentifier SchemaName   { get { return identifiers[identifiers.Length-2]; }}
            public override SqlIdentifier ObjectName   { get { return identifiers[identifiers.Length-1]; }}
            public override SqlIdentifier this[Int32 index] { get { return identifiers[index]; }}

            #region M:GetHashCode:Int32
            /// <summary>Serves as the default hash function.</summary>
            /// <returns>A hash code for the current object.</returns>
            public override Int32 GetHashCode() {
                var r = HashCodeCombiner.GetHashCode(identifiers[0]);
                for (var i = 1; i < identifiers.Length - 1; i++) {
                    r = HashCodeCombiner.GetHashCode(r,identifiers[i]);
                    }
                return r;
                }
            #endregion
            #region M:Equals(SqlObjectIdentifier):Boolean
            /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
            /// <param name="other">An object to compare with this object.</param>
            /// <returns><see langword="true"/> if the current object is equal to the <paramref name="other"/> parameter; otherwise, <see langword="false"/>.</returns>
            public override Boolean Equals(SqlObjectIdentifier other) {
                if (ReferenceEquals(null,other)) { return false; }
                if (ReferenceEquals(this,other)) { return true;  }
                if (Count==other.Count) {
                    using (var x = this.GetEnumerator())
                    using (var y = other.GetEnumerator()) {
                        if (x.MoveNext() && y.MoveNext()) {
                            if (!SqlIdentifier.Equals(x.Current, y.Current)) {
                                return false;
                                }
                            }
                        }
                    return true;
                    }
                return false;
                }
            #endregion
            }

        /// <summary>Indicates whether the current object is equal to another object of the same type.</summary>
        /// <param name="other">An object to compare with this object.</param>
        /// <returns><see langword="true"/> if the current object is equal to the <paramref name="other"/> parameter; otherwise, <see langword="false"/>.</returns>
        public abstract Boolean Equals(SqlObjectIdentifier other);

        #region M:Equals(Object):Boolean
        /// <summary>Determines whether the specified object is equal to the current object.</summary>
        /// <param name="other">The object to compare with the current object.</param>
        /// <returns><see langword="true"/> if the specified object  is equal to the current object; otherwise, <see langword="false"/>.</returns>
        public override Boolean Equals(Object other) {
            if (ReferenceEquals(null,other)) { return false; }
            if (ReferenceEquals(this,other)) { return true;  }
            return (other is SqlObjectIdentifier r) && Equals(r);
            }
        #endregion
        #region M:Equals(SqlObjectIdentifier,SqlObjectIdentifier):Boolean
        public static Boolean Equals(SqlObjectIdentifier x,SqlObjectIdentifier y) {
            if (ReferenceEquals(x,y)) { return true; }
            return !ReferenceEquals(x,null)
                ? x.Equals(y)
                : false;
            }
        #endregion
        #region M:Equals(IEnumerable<SqlObjectIdentifier>,IEnumerable<SqlObjectIdentifier>):Boolean
        public static Boolean Equals(IEnumerable<SqlObjectIdentifier> x,IEnumerable<SqlObjectIdentifier> y) {
            var seqX = x.ToArray();
            var seqY = y.ToArray();
            if (seqX.Length != seqY.Length) { return false; }
            for (var i = 0; i < seqX.Length; i++) {
                if (!seqX[i].Equals(seqY[i]))
                    {
                    return false;
                    }
                }
            return true;
            }
        #endregion
        #region M:OrderedEquals(IEnumerable<SqlObjectIdentifier>,IEnumerable<SqlObjectIdentifier>):Boolean
        public static Boolean OrderedEquals(IEnumerable<SqlObjectIdentifier> x,IEnumerable<SqlObjectIdentifier> y) {
            var seqX = x.ToArray();
            var seqY = y.ToArray();
            if (seqX.Length != seqY.Length) { return false; }
            for (var i = 0; i < seqX.Length; i++) {
                if (!seqX[i].Equals(seqY[i]))
                    {
                    return false;
                    }
                }
            return true;
            }
        #endregion
        #region M:UnorderedEquals(IEnumerable<SqlObjectIdentifier>,IEnumerable<SqlObjectIdentifier>):Boolean
        public static Boolean UnorderedEquals(IEnumerable<SqlObjectIdentifier> x,IEnumerable<SqlObjectIdentifier> y) {
            var seqX = x.OrderBy(i=>i).ToArray();
            var seqY = y.OrderBy(i=>i).ToArray();
            if (seqX.Length != seqY.Length) { return false; }
            for (var i = 0; i < seqX.Length; i++) {
                if (!seqX[i].Equals(seqY[i]))
                    {
                    return false;
                    }
                }
            return true;
            }
        #endregion
        #region M:GetHashCode:Int32
        /// <summary>Serves as the default hash function.</summary>
        /// <returns>A hash code for the current object.</returns>
        public override Int32 GetHashCode() {
            var count = Count;
            var r = 0;
            if (count > 0) {
                r = HashCodeCombiner.GetHashCode(this[0]);
                for (var i = 1; i < count - 1; i++) {
                    r = HashCodeCombiner.GetHashCode(r,this[i]);
                    }
                }
            return r;
            }
        #endregion
        #region M:CompareTo(SqlObjectIdentifier):Int32
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
        public Int32 CompareTo(SqlObjectIdentifier other) {
            Int32 r;
            if (ReferenceEquals(this,other)) { return 0; }
            if (ReferenceEquals(null,other)) { return 1; }
            r = SqlIdentifier.Compare(ServerName,other.ServerName);     if (r != 0) { return r; }
            r = SqlIdentifier.Compare(DatabaseName,other.DatabaseName); if (r != 0) { return r; }
            r = SqlIdentifier.Compare(SchemaName,other.SchemaName);     if (r != 0) { return r; }
            return SqlIdentifier.Compare(ObjectName,other.ObjectName);
            }
        #endregion
        }
    }