using System;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure
    {
    internal static class Extensions
        {
        #region M:WriteReference({this}ISqlXmlWriter,String,PDBUser)
        public static void WriteReference(this ISqlXmlWriter writer,String localName,PDBUser reference) {
            if (reference != null) {
                writer.WriteAttribute(localName,$"{{x:Reference Source=User,'{reference.FullName}',{reference.UUID.ToString("B")}}}");
                }
            }
        #endregion
        #region M:WriteReference({this}ISqlXmlWriter,String,PDBModule,SqlXmlWriterAttributeOptions)
        public static void WriteReference(this ISqlXmlWriter writer,String localName,Module reference,SqlXmlWriterAttributeOptions options) {
            if (reference != null) {
                writer.WriteAttribute(localName,$"{{x:Reference Source=Module,'{reference.Label}',{reference.OID}}}");
                }
            else
                {
                writer.WriteAttribute(localName,$"{{x:Null}}");
                }
            }
        #endregion
        #region M:WriteReference({this}ISqlXmlWriter,String,Unit,SqlXmlWriterAttributeOptions)
        public static void WriteReference(this ISqlXmlWriter writer,String localName,Unit reference,SqlXmlWriterAttributeOptions options) {
            if (reference != null) {
                writer.WriteAttribute(localName,$"{{x:Reference Source=Unit,'{reference.Label}',{reference.OID}}}");
                }
            }
        #endregion
        #region M:WriteReference({this}ISqlXmlWriter,String,PDBEntity,SqlXmlWriterAttributeOptions)
        public static void WriteReference(this ISqlXmlWriter writer,String localName,Entity reference,SqlXmlWriterAttributeOptions options) {
            if (reference != null) {
                writer.WriteAttribute(localName,$"{{x:Reference Source=Entity,'{reference.Label}',{reference.OID}}}");
                }
            else
                {
                writer.WriteAttribute(localName,$"{{x:Null}}");
                }
            }
        #endregion
        #region M:WriteReference({this}ISqlXmlWriter,String,ClassState,SqlXmlWriterAttributeOptions)
        public static void WriteReference(this ISqlXmlWriter writer,String localName,ClassState reference,SqlXmlWriterAttributeOptions options) {
            if (reference != null) {
                writer.WriteAttribute(localName,$"{{x:Reference Source=State,'{reference.Label}',{reference.OID.ToString()}}}");
                }
            else
                {
                writer.WriteAttribute(localName,$"{{x:Null}}");
                }
            }
        #endregion
        #region M:WriteReference({this}ISqlXmlWriter,String,Class,SqlXmlWriterAttributeOptions)
        public static void WriteReference(this ISqlXmlWriter writer,String localName,Class reference,SqlXmlWriterAttributeOptions options) {
            if (reference != null) {
                writer.WriteAttribute(localName,$"{{x:Reference Source=Class,'{reference.Label}',{reference.OID.ToString()}}}");
                }
            else
                {
                writer.WriteAttribute(localName,$"{{x:Null}}");
                }
            }
        #endregion
        #region M:WriteReference({this}ISqlXmlWriter,String,Query,SqlXmlWriterAttributeOptions)
        public static void WriteReference(this ISqlXmlWriter writer,String localName,Query reference,SqlXmlWriterAttributeOptions options) {
            if (reference != null) {
                writer.WriteAttribute(localName,$"{{x:Reference Source=Query,'{reference.Label}',{reference.OID}}}");
                }
            }
        #endregion
        }
    }