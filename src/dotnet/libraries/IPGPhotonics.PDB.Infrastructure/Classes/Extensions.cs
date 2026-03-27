using System;
using System.Xml;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure
    {
    internal static class Extensions
        {
        #region M:WriteReference({this}XmlWriter,Boolean,String,PDBUser)
        public static void WriteReference(this XmlWriter writer,Boolean newline,String localName,PDBUser reference) {
            if (reference != null) {
                writer.WriteAttribute(newline,localName,$"{{Reference Source=User,'{reference.FullName}',{reference.UUID.ToString("B")}}}");
                }
            }
        #endregion
        }
    }