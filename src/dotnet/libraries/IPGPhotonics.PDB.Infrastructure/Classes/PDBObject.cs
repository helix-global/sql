using System;
using System.Data;
using System.Text;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure
    {
    public class PDBObject : SqlObject
        {
        public const String URI_META  = "urn:schemas.ipg.corp:pdb:metadata";
        public const String URI_CTRL  = SqlXmlCustomWriter.URI_CTRL;

        #region ctor
        public PDBObject()
            {
            }
        #endregion
        #region ctor{DataRow}
        public PDBObject(DataRow row,IServiceProvider service)
            : base(service,row)
            {
            }
        #endregion
        #region M:EncodeString(String):String
        protected static String EncodeString(String value) {
            var r = new StringBuilder();
            foreach (var c in value) {
                if (Char.IsLetterOrDigit(c) || (c == '_')) {
                    r.Append(c);
                    }
                else
                    {
                    if (c <= 0xFF) {
                        r.AppendFormat("%{0:x2}",(Int32)c);
                        }
                    else
                        {
                        r.AppendFormat("%{0:x4}",(Int32)c);
                        }
                    }
                }
            return r.ToString();
            }
        #endregion
        #region M:DecodeLanguageString(String):String
        protected static String DecodeLanguageString(String value) {
            if (String.IsNullOrWhiteSpace(value)) { return value; }
            if (IsMatch(value, @"^(.+?)[\[]\w+[=]",out var match)) {
                return match.Groups[1].Value;
                }
            return value;
            }
        #endregion
        protected static Boolean IsNotDefault<T>(T value)
            {
            return !Equals(value,default);
            }
        protected static Boolean IsNotDefault(Boolean value)
            {
            return value;
            }
        }
    }