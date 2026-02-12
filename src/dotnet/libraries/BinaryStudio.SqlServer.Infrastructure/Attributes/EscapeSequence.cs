using System;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class EscapeSequence
        {
        public static readonly EscapeSequence BracketedEscapeSequence = new EscapeSequence('[', ']');
        public static readonly EscapeSequence DoubleQuotedEscapeSequence = new EscapeSequence('"', '"');
        public static readonly EscapeSequence SingleQuotedEscapeSequence = new EscapeSequence('\'', '\'');
        private static readonly EscapeSequence DoubleQuotedSkipOneEscapeSequence = new EscapeSequence('"', '"', 1);
        private static readonly EscapeSequence SingleQuotedSkipOneEscapeSequence = new EscapeSequence('\'', '\'', 1);
        public Char StartChar { get; }
        public Char EndChar { get; }
        public Int32 StartIndex { get; }

        #region ctor{char,char}
        private EscapeSequence(Char start, Char end)
            : this(start, end, 0)
            {
            }
        #endregion
        #region ctor{char,char,Int32}
        private EscapeSequence(Char start, Char end, Int32 startIndex)
            {
            StartChar = start;
            EndChar = end;
            StartIndex = startIndex;
            }
        #endregion

        #region M:Escape(String):String
        public String Escape(String value) {
            var array = new Char[value.Length * 2 + 2];
            var length = 0;
            array[length++] = StartChar;
            foreach (var c in value)
                {
                array[length++] = c;
                if (c == EndChar)
                    {
                    array[length++] = EndChar;
                    }
                }
            array[length++] = EndChar;
            return new String(array, 0, length);
            }
        #endregion
        #region M:IdentifyEscapeSequence(String):EscapeSequence
        public static EscapeSequence IdentifyEscapeSequence(String value) {
            if (BracketedEscapeSequence.Matches(value)) { return BracketedEscapeSequence; }
            if (DoubleQuotedEscapeSequence.Matches(value)) { return DoubleQuotedEscapeSequence; }
            if (SingleQuotedEscapeSequence.Matches(value)) { return SingleQuotedEscapeSequence; }
            return null;
            }
        #endregion
        #region M:IdentifyLiteralEscapeSequence(String):EscapeSequence
        private static EscapeSequence IdentifyLiteralEscapeSequence(String value) {
            EscapeSequence result = null;
            if (value.Length > 0) {
                if (value[0] == 'N') {
                         if (SingleQuotedSkipOneEscapeSequence.Matches(value)) { result = SingleQuotedSkipOneEscapeSequence; }
                    else if (DoubleQuotedSkipOneEscapeSequence.Matches(value)) { result = DoubleQuotedSkipOneEscapeSequence; }
                    }
                else if (SingleQuotedEscapeSequence.Matches(value)) { result = SingleQuotedEscapeSequence; }
                else if (DoubleQuotedEscapeSequence.Matches(value)) { result = DoubleQuotedEscapeSequence; }
                }
            return result;
            }
        #endregion
        #region M:Matches(String):Boolean
        private Boolean Matches(String value)
            {
            return (StartIndex < value.Length) && (value[StartIndex] == StartChar);
            }
        #endregion
        #region M:Unescape(String):String
        public String Unescape(String value) {
            if (!Matches(value)) { return value; }
            var array = new Char[value.Length];
            var length = 0;
            for (var i = StartIndex + 1; i < value.Length; i++) {
                var c = value[i];
                if (c == EndChar) {
                    if (i == value.Length - 1)
                        {
                        break;
                        }
                    if (value[i + 1] == EndChar)
                        {
                        i++;
                        }
                    }
                array[length++] = c;
                }
            var r = new String(array, 0, length);
            return r;
            }
        #endregion
        #region M:UnescapeIdentifier(String):String
        public static String UnescapeIdentifier(String value) {
            var sequence = IdentifyEscapeSequence(value);
            return (sequence != null)
                ? sequence.Unescape(value)
                : value;
            }
        #endregion
        #region M:UnescapeLiteral(String,{out}Boolean):String
        public static String UnescapeLiteral(String value, out Boolean unicode) {
            if (value == null) { throw new ArgumentNullException(nameof(value)); }
            var sequence = IdentifyLiteralEscapeSequence(value);
            if (sequence != null)
                {
                unicode = sequence.StartIndex == 1;
                return sequence.Unescape(value);
                }
            unicode = false;
            return value;
            }
        #endregion
        }
    }