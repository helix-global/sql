using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public class SqlStringOptionCollection : MarshalByRefObject,IReadOnlyDictionary<String,String>
        {
        public static readonly SqlStringOptionCollection Empty = new SqlStringOptionCollection(String.Empty);

        #region ctor{IDictionary<String,String>}
        public SqlStringOptionCollection(IDictionary<String,String> source)
            {
            if (source != null) {
                foreach (var pair in source) {
                    m_values.Add(pair.Key,pair.Value);
                    }
                }
            }
        #endregion
        #region ctor{String}
        public SqlStringOptionCollection(String source) {
            if (!String.IsNullOrWhiteSpace(source)) {
                try
                    {
                    using (var reader = new StringReader(source))
                        {
                        Parse(m_values,reader);
                        }
                    }
                catch (Exception e)
                    {
                    Debug.WriteLine($"Failed to parse options string: {e}");
                    }
                }
            }
        #endregion

        #region M:GetValueOrDefault(String,String):String
        public String GetValueOrDefault(String key, String defaultValue) {
            return !TryGetValue(key, out var r)
                ? defaultValue
                : r;
            }
        #endregion
        #region M:GetValueOrDefault(String):String
        public String GetValueOrDefault(String key) {
            return GetValueOrDefault(key,null);
            }
        #endregion

        #region M:IEnumerable<KeyValuePair<String,String>>.GetEnumerator:IEnumerator<KeyValuePair<String,String>>
        public IEnumerator<KeyValuePair<String,String>> GetEnumerator()
            {
            return m_values.GetEnumerator();
            }
        #endregion
        #region M:IEnumerable.GetEnumerator:IEnumerator
        IEnumerator IEnumerable.GetEnumerator()
            {
            return GetEnumerator();
            }
        #endregion
        #region M:IReadOnlyDictionary<String,String>.ContainsKey(String):Boolean
        /// <summary>Determines whether the read-only dictionary contains an element that has the specified key.</summary>
        /// <param name="key">The key to locate.</param>
        /// <returns><see langword="true"/> if the read-only dictionary contains an element that has the specified key; otherwise, <see langword="false"/>.</returns>
        /// <exception cref="T:System.ArgumentNullException"><paramref name="key"/> is <see langword="null" />.</exception>
        public Boolean ContainsKey(String key)
            {
            return m_values.ContainsKey(key);
            }
        #endregion
        #region M:IReadOnlyDictionary<String,String>.TryGetValue(String,{out}String):Boolean
        /// <summary>Gets the value that is associated with the specified key.</summary>
        /// <param name="key">The key to locate.</param>
        /// <param name="value">When this method returns, the value associated with the specified key, if the key is found; otherwise, the default value for the type of the <paramref name="value"/> parameter. This parameter is passed uninitialized.</param>
        /// <returns><see langword="true"/> if the object that implements the <see cref="T:System.Collections.Generic.IReadOnlyDictionary`2"/> interface contains an element that has the specified key; otherwise, <see langword="false"/>.</returns>
        /// <exception cref="T:System.ArgumentNullException"><paramref name="key"/> is <see langword="null" />.</exception>
        public Boolean TryGetValue(String key, out String value)
            {
            return m_values.TryGetValue(key,out value);
            }
        #endregion

        #region P:IReadOnlyCollection<KeyValuePair<String,String>>.Count:Int32
        public Int32 Count { get{ return m_values.Count; }}
        #endregion

        public String this[String key]    { get { return m_values[key];  }}
        public IEnumerable<String> Keys   { get{ return m_values.Keys;   }}
        public IEnumerable<String> Values { get{ return m_values.Values; }}

        #region M:Parse(Dictionary<String,String>,TextReader)
        private static void Parse(Dictionary<String,String> r,TextReader reader)
            {
            Node i;
            while ((i = ReadNext(reader)) != null)
                {
                r[i.Name] = i.Value;
                }
            }
        #endregion
        #region M:ReadNext(TextReader)
        private static Node ReadNext(TextReader reader) {
            SkipWhiteSpacesAndDelimiters(reader);
            var identifier = ReadNextIdentifer(reader);
            if (String.IsNullOrEmpty(identifier)) { return null; }
            SkipWhiteSpaces(reader);
            var c = reader.Peek();
            if (c == '=') {
                reader.Read();
                SkipWhiteSpaces(reader);
                c = reader.Peek();
                if (c == '{')
                    {
                    return new Node
                        {
                        Name = identifier,
                        Value = ReadNextDecoratedString(reader)
                        };
                    }
                else
                    {
                    return new Node
                        {
                        Name = identifier,
                        Value = ReadNextString(reader)
                        };
                    }
                }
            else
                {
                return new Node
                    {
                    Name = identifier
                    };
                }
            }
        #endregion
        #region M:ReadNextIdentifer(TextReader):String
        private static String ReadNextIdentifer(TextReader reader)
            {
            var r = new StringBuilder();
            var c = reader.Peek();
            while (IsLetterOrDigit(c))
                {
                reader.Read();
                r.Append((char)c);
                c = reader.Peek();
                }
            return r.ToString();
            }
        #endregion
        #region M:ReadNextString(TextReader,Int32):String
        private static String ReadNextString(TextReader reader) {
            var r = new StringBuilder();
            var c = reader.Peek();
            while (!IsDelimiter(c) && !IsWhiteSpace(c))
                {
                reader.Read();
                r.Append((char)c);
                c = reader.Peek();
                }
            return r.ToString();
            }
        #endregion
        #region M:ReadNextDecoratedString(TextReader):String
        private static String ReadNextDecoratedString(TextReader reader) {
            var r = new StringBuilder();
            var brackets = 0;
            for (; ; ) {
                var c = reader.Peek();
                switch (c) {
                    case '{':
                            {
                            brackets++;
                            reader.Read();
                            if (brackets > 1)
                                {
                                r.Append('{');
                                }
                            }
                        break;
                    case '}':
                            {
                            if (brackets == 0) { throw new InvalidDataException("Unexpected '}'"); }
                            brackets--;
                            reader.Read();
                            if (brackets == 0)
                                {
                                return r.ToString();
                                }
                            r.Append('}');
                            }
                        break;
                    case -1:
                            {
                            if (brackets != 0) {
                                throw new InvalidDataException("Unexpected end of string");
                                }
                            return r.ToString();
                            }
                    default:
                            {
                            r.Append((char)reader.Read());
                            }
                        break;
                    }
                }
            }
        #endregion
        #region M:SkipWhiteSpaces(TextReader)
        private static void SkipWhiteSpaces(TextReader reader) {
            var c = reader.Peek();
            while (IsWhiteSpace(c)) {
                reader.Read();
                c = reader.Peek();
                }
            }
        #endregion
        #region M:SkipDelimiters(TextReader)
        private static void SkipDelimiters(TextReader reader) {
            var c = reader.Peek();
            while (IsDelimiter(c)) {
                reader.Read();
                c = reader.Peek();
                }
            }
        #endregion
        #region M:SkipWhiteSpacesAndDelimiters(TextReader)
        private static void SkipWhiteSpacesAndDelimiters(TextReader reader) {
            for (;;)
                {
                var c = reader.Peek();
                if (IsWhiteSpace(c)) {
                    SkipWhiteSpaces(reader);
                    continue;
                    }
                if (IsDelimiter(c)) {
                    SkipDelimiters(reader);
                    continue;
                    }
                break;
                }
            }
        #endregion
        #region M:IsDelimiter(Int32):Boolean
        private static Boolean IsDelimiter(Int32 value) {
            foreach (var delimiter in delimiters) {
                if (value == delimiter) {
                    return true;
                    }
                }
            return false;
            }
        #endregion
        #region M:IsWhiteSpace(Int32):Boolean
        private static Boolean IsWhiteSpace(Int32 value)
            {
            if (value == -1) { return false; }
            return Char.IsWhiteSpace((char)value);
            }
        #endregion
        #region M:IsLetterOrDigit(Int32):Boolean
        private static Boolean IsLetterOrDigit(Int32 value) {
            if (value == -1) { return false; }
            return Char.IsLetterOrDigit((char)value)
                || (value == '@')
                || (value == '_')
                || (value == '#')
                || (value == '!')
                || (value == '?')
                || (value == '/')
                || (value == '%');
            }
        #endregion

        private class Node
            {
            public String Name { get;set; }
            public String Value { get;set; }
            }

        private readonly Dictionary<String,String> m_values = new Dictionary<String,String>(StringComparer.OrdinalIgnoreCase);
        private static readonly Char[] delimiters = new []{',',';','&'};

        ///// <summary>Populates a <see cref="T:System.Runtime.Serialization.SerializationInfo" /> with the data needed to serialize the target object.</summary>
        ///// <param name="info">The <see cref="T:System.Runtime.Serialization.SerializationInfo" /> to populate with data.</param>
        ///// <param name="context">The destination (see <see cref="T:System.Runtime.Serialization.StreamingContext" />) for this serialization.</param>
        ///// <exception cref="T:System.Security.SecurityException">The caller does not have the required permission.</exception>
        //public void GetObjectData(SerializationInfo info, StreamingContext context) {
        //    info.AddValue("Count",m_values.Count);
        //    var i = 0;
        //    foreach (var pair in m_values) {
        //        info.AddValue($"K:{i.ToString("x4")}",pair.Key);
        //        info.AddValue($"T:{i.ToString("x4")}",pair.Value);
        //        i++;
        //        }
        //    }

        ///// <summary>The special constructor is used to deserialize values.</summary>
        ///// <param name="info">The data needed to deserialize an object.</param>
        ///// <param name="context">Describes the source of a given serialized stream, and provides an additional caller-defined context.</param>
        //protected ParameterCollection(SerializationInfo info, StreamingContext context) {
        //    if (info == null) { throw new ArgumentNullException(nameof(info)); }
        //    var count = info.GetInt32("Count");
        //    for (var i = 0; i < count; i++) {
        //        m_values[info.GetString($"K:{i.ToString("x4")}")] = $"T:{i.ToString("x4")}";
        //        }
        //    }
        #region M:ToString:String
        public override string ToString()
            {
            var r = new StringBuilder();
            foreach (var pair in m_values) {
                if (r.Length > 0) { r.Append(','); }
                r.Append(pair.Key);
                if (!String.IsNullOrEmpty(pair.Value)) {
                    r.Append('=');
                    if (pair.Value.IndexOfAny(delimiters) >= 0)
                        {
                        r.Append('{');
                        r.Append(pair.Value
                            .Replace("{","{{")
                            .Replace("}","}}")
                            .Replace("\n","\\n")
                            .Replace("\r","\\r")
                            .Replace("\t","\\t"));
                        r.Append('}');
                        }
                    else
                        {
                        r.Append(pair.Value);
                        }
                    }
                }
            return r.ToString();
            }
        #endregion
        }
    }