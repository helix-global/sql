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
        public PDBUser CreatedBy  { get; }
        public PDBUser ModifiedBy { get; }

        #region ctor{ISqlObjectResolver<Int32?,PDBUser>,DataRow}
        internal PDBEnumValue(ISqlObjectResolver<Int32?,PDBUser> Users,DataRow row)
            :base(row)
            {
            CreatedBy  = Users.GetObject(PropSI4(row["S_CR"]));
            ModifiedBy = Users.GetObject(PropSI4(row["S_MR"]));
            }
        #endregion

        #region M:WriteXml(ISqlXmlWriter)
        /// <summary>Converts an object into its XML representation.</summary>
        /// <param name="writer">The <see cref="T:BinaryStudio.SqlServer.Infrastructure.ISqlXmlWriter"/> stream to which the object is serialized.</param>
        public override void WriteXml(ISqlXmlWriter writer) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            using (writer.ElementGroup("EnumValue",URI_META)) {
                writer.ScheduleNewLineForNextAttribute().WriteAttribute(nameof(OID),OID);
                writer.WriteAttribute(nameof(Code),Code);
                writer.WriteAttribute(nameof(UUID),UUID);
                writer.ScheduleNewLineForNextAttribute().WriteAttribute(nameof(CreatedDate),CreatedDate);
                writer.WriteAttribute(nameof(ModifiedDate),ModifiedDate);
                writer.ScheduleNewLineForNextAttribute().WriteReference(nameof(CreatedBy),CreatedBy);
                writer.ScheduleNewLineForNextAttribute().WriteReference(nameof(ModifiedBy),ModifiedBy);
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