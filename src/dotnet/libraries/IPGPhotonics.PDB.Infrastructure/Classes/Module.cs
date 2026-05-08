using System;
using System.Data;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    public class Module : PDBObject
        {
        [UsedImplicitly][Field(Source = "NAME")]   public String Name { get; }
        [UsedImplicitly][Field(Source = "LABEL")]  public String Label { get; }
        [UsedImplicitly][Field(Source = "REMARK")] public String Description { get; }
        [UsedImplicitly][Field(Source = "OID")]    public Int32 OID { get; }
        [UsedImplicitly][Field(Source = "GID")]    public Guid UUID { get; }
        [UsedImplicitly][Field(Source = "S_CDT")]  public DateTime? CreatedDate  { get; }
        [UsedImplicitly][Field(Source = "S_MDT")]  public DateTime? ModifiedDate { get; }
        public PDBUser CreatedBy  { get; }
        public PDBUser ModifiedBy { get; }

        #region ctor{DataRow,IServiceProvider,ISqlObjectResolver<Int32?,User>}
        public Module(DataRow row,IServiceProvider service,ISqlObjectResolver<Int32?,PDBUser> Users)
            : base(row,service)
            {
            CreatedBy  = Users.GetObject(PropSI4(row["S_CR"]));
            ModifiedBy = Users.GetObject(PropSI4(row["S_MR"]));
            }
        #endregion

        #region M:WriteXml(ISqlXmlWriter)
        /// <summary>Converts an object into its XML representation.</summary>
        /// <param name="writer">The <see cref="ISqlXmlWriter"/> stream to which the object is serialized.</param>
        public override void WriteXml(ISqlXmlWriter writer) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            using (writer.ElementGroup("Module",URI_META)) {
                writer.WriteAttribute("xmlns","xsi",null,URI_XSINIL);
                writer.WriteAttribute("xmlns","",null,URI_META);
                writer.ScheduleNewLineForNextAttribute().WriteAttribute(nameof(Label),Label);
                writer.ScheduleNewLineForNextAttribute().WriteAttribute(nameof(OID),OID);
                writer.WriteAttribute(nameof(UUID),UUID);
                writer.ScheduleNewLineForNextAttribute().WriteAttribute(nameof(CreatedDate),CreatedDate);
                writer.WriteAttribute(nameof(ModifiedDate),ModifiedDate);
                writer.ScheduleNewLineForNextAttribute().WriteReference(nameof(CreatedBy),CreatedBy);
                writer.ScheduleNewLineForNextAttribute().WriteReference(nameof(ModifiedBy),ModifiedBy);
                writer.WriteCData(nameof(Name),URI_META,Name);
                if (!String.IsNullOrEmpty(Description)) {
                    writer.WriteCData("Description",URI_META,Description);
                    }
                }
            }
        #endregion
        #region M:ToString():String
        public override String ToString()
            {
            return $"{Label}";
            }
        #endregion
        }
    }
