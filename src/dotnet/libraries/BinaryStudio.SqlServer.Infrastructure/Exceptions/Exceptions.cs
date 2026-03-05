using System;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public static class Exceptions
        {
        #region M:Add<T>({this}T,String,Object):T
        public static T Add<T>(this T e, String key, Object value)
            where T: Exception
            {
            if (value != null) {
                var type = value.GetType();
                if ((value is ISerializable) ||
                    (type.GetCustomAttributes(typeof(SerializableAttribute),true).Any()) ||
                    (type.IsEnum))
                    {
                    e.Data[key] = value;
                    }
                else if (value is Byte[]) {
                    var r = (Byte[])value;
                    #if NET35
                    e.Data[key] = (r.Length <= 64)
                        ? "{base32}:" + String.Join(String.Empty, r.Select(i => i.ToString("x2")).ToArray())
                        : "{base64}:" + LineBefore(Convert.ToBase64String(r, Base64FormattingOptions.InsertLineBreaks));
                    #else
                    e.Data[key] = (r.Length <= 64)
                        ? "{base32}:" + String.Join(String.Empty, r.Select(i => i.ToString("x2")))
                        : "{base64}:" + LineBefore(Convert.ToBase64String(r, Base64FormattingOptions.InsertLineBreaks));
                    #endif
                    }
                else
                    {
                    }
                }
            return e;
            }
        #endregion
        #region M:AddIfNotEmpty<T>({this}T,String,String):T
        public static T AddIfNotEmpty<T>(this T e,String key,String value)
            where T: Exception
            {
            if (!String.IsNullOrWhiteSpace(value)) {
                e.Add(key,value);
                }
            return e;
            }
        #endregion
        #region M:LineBefore(String):String
        private static String LineBefore(String source) {
            var o = source.Split(new []{'\r','\n'}, StringSplitOptions.RemoveEmptyEntries);
            if (o.Length > 1) {
                var r = new StringBuilder();
                r.AppendLine();
                foreach (var i in o) {
                    r.AppendLine(i);
                    }
                return r.ToString().TrimEnd('\r', '\n');
                }
            return source;
            }
        #endregion

        public static String Format(Exception e) {
            if (e == null) { throw new ArgumentNullException(nameof(e)); }
            return new ExceptionFormat().ToString(e);
            }
        }
    }
