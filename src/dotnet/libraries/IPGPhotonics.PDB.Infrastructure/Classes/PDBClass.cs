using System;
using System.Collections.Generic;
using System.Data;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    public class PDBClass : PDBObject
        {
        public IDictionary<Int32,ClassState> States { get; }
        [UsedImplicitly][Field("OID")]       public Int32 OID { get; }
        [UsedImplicitly][Field("NAME")]      public String Name { get; }
        [UsedImplicitly][Field("LABEL")]     public String Label { get; }
        [UsedImplicitly][Field("MODULEOID")] private Int32 ModuleOID { get; }
        [UsedImplicitly][Field("REMARK")] public String Description { get; }
        [UsedImplicitly][Field("DOPTION")] public String Options { get; }
        [UsedImplicitly][Field("S_CDT")]  public DateTime? CreatedDate  { get; }
        [UsedImplicitly][Field("S_MDT")]  public DateTime? ModifiedDate { get; }
        [UsedImplicitly][Field("GID")]    public Guid UUID { get; }
        [UsedImplicitly][Field("SPELLCHECKER")] public Boolean SpellCheckingDisabled { get; }
        [UsedImplicitly][Field("ENTITYOID")] private Int32? EntityOID { get; }
        public PDBUser CreatedBy  { get; }
        public PDBUser ModifiedBy { get; }
        public PDBModule Module { get; }
        public PDBEntity Entity { get; }

        #region ctor{DataRow,ISqlObjectResolver<Int32?,PDBUser>,ISqlObjectResolver<Int32?,PDBModule>,ISqlObjectResolver<Int32?,PDBModule>,IDictionary<Int32,IList<DataRow>>}
        internal PDBClass(DataRow source,ISqlObjectResolver<Int32?,PDBUser> users,ISqlObjectResolver<Int32?,PDBModule> modules,ISqlObjectResolver<Int32?,PDBEntity> entities,IDictionary<Int32,IList<DataRow>> states)
            :base(source)
            {
            CreatedBy  = users.GetObject(PropSI4(source["S_CR"]));
            ModifiedBy = users.GetObject(PropSI4(source["S_MR"]));
            Module = modules.GetObject(ModuleOID);
            Entity = entities.GetObject(EntityOID);
            States = new Dictionary<Int32,ClassState>();
            try
                {
                if (states.TryGetValue(OID,out var rows)) {
                    foreach (var row in rows) {
                        var o = new ClassState(row,users);
                        States.Add(o.OID,o);
                        }
                    }
                }
            finally
                {
                States = States.AsReadOnly();
                }
            }
        #endregion

        #region M:WriteXml(ISqlXmlWriter)
        /// <summary>Converts an object into its XML representation.</summary>
        /// <param name="writer">The <see cref="T:BinaryStudio.SqlServer.Infrastructure.ISqlXmlWriter"/> stream to which the object is serialized.</param>
        public override void WriteXml(ISqlXmlWriter writer) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            using (writer.ElementGroup("Class",URI_META)) {
                writer.WriteAttribute("xmlns","xsi",null,URI_XSINIL);
                writer.WriteAttribute("xmlns","",null,URI_META);
                writer.WriteAttribute("xmlns","x",null,URI_CTRL);
                using (writer.NewLineOnAttribute())
                    {
                    writer.WriteAttribute(nameof(Label),Label);
                    writer.WriteAttribute(nameof(OID),OID);
                    }
                writer.WriteAttribute(nameof(UUID),UUID);
                using (writer.NewLineOnAttribute())
                    {
                    writer.WriteAttribute(nameof(CreatedDate),CreatedDate);
                    }
                writer.WriteAttribute(nameof(ModifiedDate),ModifiedDate);
                using (writer.NewLineOnAttribute())
                    {
                    writer.WriteReferenceIfNotNull(nameof(CreatedBy),CreatedBy);
                    writer.WriteReferenceIfNotNull(nameof(ModifiedBy),ModifiedBy);
                    writer.WriteReference(nameof(Module),Module);
                    writer.WriteReference(nameof(Entity),Entity);
                    }
                if (SpellCheckingDisabled) { writer.WriteAttribute(nameof(SpellCheckingDisabled),SpellCheckingDisabled); }
                using (writer.NewLineOnAttribute())
                    {
                    
                    }
                writer.WriteCData(nameof(Name),URI_META,Name);
                writer.WriteCData(nameof(Options),URI_META,Options);
                writer.WriteCData(nameof(Description),URI_META,Description);
                if (States.Count > 0) {
                    using (writer.ElementGroup("States",URI_META)) {
                        foreach (var o in States.Values) {
                            o.WriteXml(writer);
                            }
                        }
                    }
                }
            }
        #endregion
        #region M:ToString():String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return $"{Label}";
            }
        #endregion
        }
    }