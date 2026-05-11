using System;
using System.ComponentModel;
using System.Data;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    public class PDBEnumValue : PDBObject
        {
        [UsedImplicitly][Field("CODE")] public Int32 Code { get; }
        [UsedImplicitly][Field("NAME")] public String Value { get; }
        [UsedImplicitly][Field("OID")]  public Int32 OID { get; }
        [UsedImplicitly][Field("GID")]    public Guid UUID { get; }
        [UsedImplicitly][Field("S_CDT")]  public DateTime? CreatedDate  { get; }
        [UsedImplicitly][Field("S_MDT")]  public DateTime? ModifiedDate { get; }
        [UsedImplicitly][Field("ENUMPICT")][TypeConverter(typeof(SqlBase64ArrayConverter))] public Byte[] Picture { get; }
        [UsedImplicitly][Field("S_CR")]   public PDBUser CreatedBy  { get; }
        [UsedImplicitly][Field("S_MR")]   public PDBUser ModifiedBy { get; }

        #region ctor{DataRow,IServiceProvider}
        internal PDBEnumValue(DataRow row,IServiceProvider service)
            :base(row,service)
            {
            }
        #endregion

        #region M:WriteXml(ISqlXmlWriter)
        /// <summary>Converts an object into its XML representation.</summary>
        /// <param name="writer">The <see cref="T:BinaryStudio.SqlServer.Infrastructure.ISqlXmlWriter"/> stream to which the object is serialized.</param>
        public override void WriteXml(ISqlXmlWriter writer) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            using (writer.ElementGroup("EnumValue",URI_META)) {
                writer.WriteAttribute(nameof(OID),OID);
                writer.WriteAttribute(nameof(Code),Code);
                writer.WriteAttribute(nameof(UUID),UUID);
                writer.ScheduleNewLineForNextAttribute().WriteAttribute(nameof(CreatedDate),CreatedDate);
                writer.WriteAttribute(nameof(ModifiedDate),ModifiedDate);
                writer.ScheduleNewLineForNextAttribute().WriteReference(nameof(CreatedBy),CreatedBy);
                writer.ScheduleNewLineForNextAttribute().WriteReference(nameof(ModifiedBy),ModifiedBy);
                writer.StopScheduleNewLineForNextAttribute();
                writer.WriteCData(nameof(Value),URI_META,Value);
                writer.WriteBase64(nameof(Picture),URI_META,Picture);
                }
            }
        #endregion
        #region M:ToString():String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return $"{Value}";
            }
        #endregion
        }
    }