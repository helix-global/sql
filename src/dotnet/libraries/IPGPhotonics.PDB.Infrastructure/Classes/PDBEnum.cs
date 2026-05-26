using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [TypeConverter(typeof(ObjectConverter<PDBEnum>))]
    public class PDBEnum : PDBObject
        {
        public IList<PDBEnumValue> Values { get; }
        [UsedImplicitly][Field("OID")]       public Int32 OID { get; }
        [UsedImplicitly][Field("NAME")]      public String Name { get; }
        [UsedImplicitly][Field("LABEL")]     public String Label { get; }
        [UsedImplicitly][Field("S_CDT")]     public DateTime? CreatedDate  { get; }
        [UsedImplicitly][Field("S_MDT")]     public DateTime? ModifiedDate { get; }
        [UsedImplicitly][Field("GID")]       public Guid UUID { get; }
        [UsedImplicitly][Field("S_CR")]      public User CreatedBy  { get; }
        [UsedImplicitly][Field("S_MR")]      public User ModifiedBy { get; }
        [UsedImplicitly][Field("MODULEOID")] public Module Module { get; }

        #region ctor{DataRow,IServiceProvider,IDictionary<Int32,IList<DataRow>>}
        internal PDBEnum(DataRow source,IServiceProvider service,IDictionary<Int32,IList<DataRow>> values)
            :base(source,service)
            {
            Values = new List<PDBEnumValue>();
            try
                {
                if (values.TryGetValue(OID,out var rows)) {
                    foreach (var row in rows) {
                        var o = new PDBEnumValue(row,service);
                        Values.Add(o);
                        }
                    }
                }
            finally
                {
                Values = Values.AsReadOnly();
                }
            }
        #endregion

        #region M:WriteXml(ISqlXmlWriter)
        /// <summary>Converts an object into its XML representation.</summary>
        /// <param name="writer">The <see cref="T:BinaryStudio.SqlServer.Infrastructure.ISqlXmlWriter"/> stream to which the object is serialized.</param>
        public override void WriteXml(ISqlXmlWriter writer) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            using (writer.ElementGroup("Enum",URI_META)) {
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
                writer.ScheduleNewLineForNextAttribute().WriteReference(nameof(Module),Module);
                writer.StopScheduleNewLineForNextAttribute();
                writer.WriteCData(nameof(Name),URI_META,Name);
                if (Values.Count > 0) {
                    using (writer.ElementGroup("Values",URI_META)) {
                        foreach (var o in Values) {
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