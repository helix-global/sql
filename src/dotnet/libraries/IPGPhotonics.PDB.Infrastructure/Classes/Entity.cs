using System;
using System.Data;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;
using static BinaryStudio.SqlServer.Infrastructure.SqlXmlWriterAttributeOptions;

namespace IPGPhotonics.PDB.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    public class Entity : PDBObject
        {
        [UsedImplicitly][Field("OID")]       public Int32 OID { get; }
        [UsedImplicitly][Field("NAME")]      public String Name { get; }
        [UsedImplicitly][Field("LABEL")]     public String Label { get; }
        [UsedImplicitly][Field("S_CDT")]     public DateTime? CreatedDate  { get; }
        [UsedImplicitly][Field("S_MDT")]     public DateTime? ModifiedDate { get; }
        [UsedImplicitly][Field("GID")]       public Guid UUID { get; }
        [UsedImplicitly][Field("MAINTABLE")] public String MainTable { get; }
        [UsedImplicitly][Field("IDFIELDNAME")] public String IdentityFieldName { get; }
        [UsedImplicitly][Field("MODULEOID")] private Int32 ModuleOID { get; }
        [UsedImplicitly][Field("DATAUNITOID")] private Int32? DataUnitOID { get; }
        [UsedImplicitly][Field("REMARKS")]     public String Description { get; }
        [UsedImplicitly][Field("STATESCOUNT")] public EntityStateKind EntityStates { get; }
        [UsedImplicitly][Field("SQLFILTER")]   public String FilterExpression { get; }
        public PDBUser CreatedBy  { get; }
        public PDBUser ModifiedBy { get; }
        public Module Module { get; }
        public Unit DataUnit { get; }

        #region ctor{IServiceProvider,DataRow}
        internal Entity(IServiceProvider provider,DataRow source)
            :base(source)
            {
            var users     = (ISqlObjectResolver<Int32?,PDBUser>)provider.GetService(typeof(ISqlObjectResolver<Int32?,PDBUser>));
            var modules   = (ISqlObjectResolver<Int32?,Module>)provider.GetService(typeof(ISqlObjectResolver<Int32?,Module>));
            var DataUnits = (ISqlObjectResolver<Int32?,Unit>)provider.GetService(typeof(ISqlObjectResolver<Int32?,Unit>));
            CreatedBy  = users.GetObject(PropSI4(source["S_CR"]));
            ModifiedBy = users.GetObject(PropSI4(source["S_MR"]));
            Module = modules.GetObject(ModuleOID);
            DataUnit = DataUnits.GetObject(DataUnitOID);
            }
        #endregion

        #region M:WriteXml(ISqlXmlWriter)
        /// <summary>Converts an object into its XML representation.</summary>
        /// <param name="writer">The <see cref="T:BinaryStudio.SqlServer.Infrastructure.ISqlXmlWriter"/> stream to which the object is serialized.</param>
        public override void WriteXml(ISqlXmlWriter writer) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            using (writer.ElementGroup("Entity",URI_META)) {
                writer.WriteAttribute("xmlns","xsi",null,URI_XSINIL);
                writer.WriteAttribute("xmlns","",null,URI_META);
                writer.WriteAttribute("xmlns","x",null,URI_CTRL);
                writer.ScheduleNewLineForNextAttribute().WriteAttribute(nameof(Label),Label);
                writer.WriteAttribute(nameof(OID),OID);
                writer.WriteAttribute(nameof(UUID),UUID);
                writer.ScheduleNewLineForNextAttribute().WriteAttribute(nameof(CreatedDate),CreatedDate);
                writer.WriteAttribute(nameof(ModifiedDate),ModifiedDate);
                writer.ScheduleNewLineForNextAttribute().WriteReference(nameof(CreatedBy),CreatedBy);
                writer.ScheduleNewLineForNextAttribute().WriteReference(nameof(ModifiedBy),ModifiedBy);
                writer.ScheduleNewLineForNextAttribute().WriteReference(nameof(Module),Module,None);
                writer.ScheduleNewLineForNextAttribute().WriteReference(nameof(DataUnit),DataUnit,None);
                writer.ScheduleNewLineForNextAttribute().WriteAttribute(nameof(IdentityFieldName),IdentityFieldName);
                writer.WriteAttribute(nameof(EntityStates),EntityStates);
                writer.WriteCData(nameof(Name),URI_META,Name);
                writer.WriteCData(nameof(MainTable),URI_META,MainTable);
                writer.WriteCData(nameof(FilterExpression),URI_META,FilterExpression);
                writer.WriteCData(nameof(Description),URI_META,Description);
                }
            }
        #endregion
        }
    }