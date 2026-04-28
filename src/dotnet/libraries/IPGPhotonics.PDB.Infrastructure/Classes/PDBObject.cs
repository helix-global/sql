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
        public PDBObject(DataRow row)
            : base(row)
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
        }
    }