using System;
using System.Globalization;
using System.Xml;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal static class XmlExceptions
        {
        #region M:CreateInvalidSurrogatePairException(Char,Char):Exception
        public static Exception CreateInvalidSurrogatePairException(Char low, Char hi)
            {
            throw new XmlException(String.Format("The surrogate pair (0x{0}, 0x{1}) is invalid. A high surrogate character (0xD800 - 0xDBFF) must always be paired with a low surrogate character (0xDC00 - 0xDFFF).", low, hi));
            }
        #endregion
        #region M:CreateInvalidHighSurrogateCharException(Char):Exception
        public static Exception CreateInvalidHighSurrogateCharException(Char hi)
            {
            throw new XmlException(String.Format("Invalid high surrogate character (0x{0}). A high surrogate character must have a value from range (0xD800 - 0xDBFF).", hi));
            }
        #endregion
        #region M:CreateInvalidCharException(Char,Char):Exception
        public static Exception CreateInvalidCharException(Char inv, Char next)
            {
            throw new XmlException(String.Format("'{0}', hexadecimal value {1}, is an invalid character.", BuildCharExceptionArgs(inv, next)));
            }
        #endregion
        public static Object[] BuildCharExceptionArgs(char invChar, char nextChar)
            {
            string[] array = new string[2];
            if (XmlCharType.IsHighSurrogate(invChar) && nextChar != 0)
                {
                int num = XmlCharType.CombineSurrogateChar(nextChar, invChar);
                array[0] = new string(new char[2] { invChar, nextChar });
                array[1] = string.Format(CultureInfo.InvariantCulture, "0x{0:X2}", new object[1] { num });
                }
            else
                {
                if (invChar == '\0')
                    {
                    array[0] = ".";
                    }
                else
                    {
                    array[0] = invChar.ToString(CultureInfo.InvariantCulture);
                    }
                array[1] = string.Format(CultureInfo.InvariantCulture, "0x{0:X2}", new object[1] { (int)invChar });
                }
            return array;
            }
        public static Object[] BuildCharExceptionArgs(string data, int invCharIndex)
            {
            return BuildCharExceptionArgs(data[invCharIndex], (invCharIndex + 1 < data.Length) ? data[invCharIndex + 1] : '\0');
            }
        public static Object[] BuildCharExceptionArgs(char[] data, int invCharIndex)
            {
            return BuildCharExceptionArgs(data, data.Length, invCharIndex);
            }
        public static Object[] BuildCharExceptionArgs(char[] data, int length, int invCharIndex)
            {
            return BuildCharExceptionArgs(data[invCharIndex], (invCharIndex + 1 < length) ? data[invCharIndex + 1] : '\0');
            }
        }
    }