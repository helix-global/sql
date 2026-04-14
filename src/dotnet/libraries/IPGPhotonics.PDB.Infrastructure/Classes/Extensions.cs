using System;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure
    {
    internal static class Extensions
        {
        #region M:WriteReference({this}ISqlXmlWriter,String,PDBUser)
        public static void WriteReference(this ISqlXmlWriter writer,String localName,PDBUser reference) {
            if (reference != null) {
                writer.WriteAttribute(localName,$"{{Reference Source=User,'{reference.FullName}',{reference.UUID.ToString("B")}}}");
                }
            }
        #endregion
        #region M:WriteReference({this}ISqlXmlWriter,String,PDBModule)
        public static void WriteReference(this ISqlXmlWriter writer,String localName,PDBModule reference) {
            if (reference != null) {
                writer.WriteAttribute(localName,$"{{Reference Source=Module,'{reference.Label}',{reference.OID.ToString()}}}");
                }
            }
        #endregion
        }
    }