using System;
using System.Reflection;
using System.Xml;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class SqlXmlConvert
        {
        internal static String VerifyQName(String name,ExceptionType exceptionType) {
            var type = typeof(XmlConvert);
            var mi = type.GetMethod("VerifyQName",BindingFlags.Static|BindingFlags.NonPublic,null,new []{typeof(String),m_xcpT},null);
            return (String)mi.Invoke(null,new Object[]{ name, (Int32)exceptionType});
            }

        internal static string TrimString(string value)
            {
            return value.Trim(WhitespaceChars);
            }

        internal static string TrimStringStart(string value)
            {
            return value.TrimStart(WhitespaceChars);
            }

        internal static string TrimStringEnd(string value)
            {
            return value.TrimEnd(WhitespaceChars);
            }

        private static Type m_xcpT = typeof(XmlConvert).Assembly.GetType("System.Xml.ExceptionType");
        internal static readonly char[] WhitespaceChars = new char[4] { ' ', '\t', '\n', '\r' };
        }
    }