using System;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure
    {
    internal static class Extensions
        {
        #region M:WriteReference({this}ISqlXmlWriter,String,PDBUser)
        public static void WriteReferenceIfNotNull(this ISqlXmlWriter writer,String localName,PDBUser reference) {
            if (reference != null) {
                writer.WriteAttribute(localName,$"{{x:Reference Source=User,'{reference.FullName}',{reference.UUID.ToString("B")}}}");
                }
            }
        #endregion
        #region M:WriteReference({this}ISqlXmlWriter,String,PDBModule)
        public static void WriteReferenceIfNotNull(this ISqlXmlWriter writer,String localName,PDBModule reference) {
            if (reference != null) {
                writer.WriteAttribute(localName,$"{{x:Reference Source=Module,'{reference.Label}',{reference.OID.ToString()}}}");
                }
            }
        #endregion
        #region M:WriteReference({this}ISqlXmlWriter,String,PDBModule)
        public static void WriteReference(this ISqlXmlWriter writer,String localName,PDBModule reference) {
            if (reference != null) {
                writer.WriteAttribute(localName,$"{{x:Reference Source=Module,'{reference.Label}',{reference.OID.ToString()}}}");
                }
            else
                {
                writer.WriteAttribute(localName,$"{{x:Null}}");
                }
            }
        #endregion
        #region M:WriteReference({this}ISqlXmlWriter,String,PDBDataUnit)
        public static void WriteReferenceIfNotNull(this ISqlXmlWriter writer,String localName,PDBDataUnit reference) {
            if (reference != null) {
                writer.WriteAttribute(localName,$"{{x:Reference Source=DataUnit,'{reference.Label}',{reference.OID.ToString()}}}");
                }
            }
        #endregion
        #region M:WriteReference({this}ISqlXmlWriter,String,PDBEntity)
        public static void WriteReferenceIfNotNull(this ISqlXmlWriter writer,String localName,PDBEntity reference) {
            if (reference != null) {
                writer.WriteAttribute(localName,$"{{x:Reference Source=Entity,'{reference.Label}',{reference.OID.ToString()}}}");
                }
            }
        #endregion
        #region M:WriteReference({this}ISqlXmlWriter,String,PDBEntity)
        public static void WriteReference(this ISqlXmlWriter writer,String localName,PDBEntity reference) {
            if (reference != null) {
                writer.WriteAttribute(localName,$"{{x:Reference Source=Entity,'{reference.Label}',{reference.OID.ToString()}}}");
                }
            else
                {
                writer.WriteAttribute(localName,$"{{x:Null}}");
                }
            }
        #endregion
        #region M:WriteReference({this}ISqlXmlWriter,String,ClassState)
        public static void WriteReference(this ISqlXmlWriter writer,String localName,ClassState reference) {
            if (reference != null) {
                writer.WriteAttribute(localName,$"{{x:Reference Source=State,'{reference.Label}',{reference.OID.ToString()}}}");
                }
            else
                {
                writer.WriteAttribute(localName,$"{{x:Null}}");
                }
            }
        #endregion
        #region M:WriteReference({this}ISqlXmlWriter,String,Class)
        public static void WriteReference(this ISqlXmlWriter writer,String localName,PDBClass reference) {
            if (reference != null) {
                writer.WriteAttribute(localName,$"{{x:Reference Source=Class,'{reference.Label}',{reference.OID.ToString()}}}");
                }
            else
                {
                writer.WriteAttribute(localName,$"{{x:Null}}");
                }
            }
        #endregion
        }
    }