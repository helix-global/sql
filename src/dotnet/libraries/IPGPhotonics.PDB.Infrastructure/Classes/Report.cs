#define FEATURE_FASTREPORT_CHECK
using System;
using System.ComponentModel;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using System.Xml;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;
using IPGPhotonics.PDB.Infrastructure.Reports;
using System.Diagnostics;

namespace IPGPhotonics.PDB.Infrastructure
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [TypeConverter(typeof(ObjectConverter<Report>))]
    public class Report : PDBObject
        {
        [UsedImplicitly][Field("OID")]       public Int32 OID { get; }
        [UsedImplicitly][Field("NAME")]      public String Name { get; }
        [UsedImplicitly][Field("LABEL")]     public String Label { get; }
        [UsedImplicitly][Field("S_CDT")]     public DateTime? CreatedDate  { get; }
        [UsedImplicitly][Field("S_MDT")]     public DateTime? ModifiedDate { get; }
        [UsedImplicitly][Field("GID")]       public Guid UUID { get; }
        [UsedImplicitly][Field("S_CR")]      public User CreatedBy  { get; }
        [UsedImplicitly][Field("S_MR")]      public User ModifiedBy { get; }
        [UsedImplicitly][Field("MODULEOID")] public Module Module { get; }
        [UsedImplicitly][Field("S_S")]       public ClassState State { get; }
        [UsedImplicitly][Field("REMARK")]    public String Description { get; }
        [UsedImplicitly][Field("ISOCODE")]   public String ISO { get; }
        [UsedImplicitly][Field("OPTIONS")]   public String Options { get; }
        internal FastReport Body { get; }

        #region ctor{DataRow,IServiceProvider}
        internal Report(DataRow source,IServiceProvider service)
            :base(source,service)
            {
            if (body != null) {
                Body = FastReport.LoadFrom(body);
                #if FEATURE_FASTREPORT_CHECK
                try
                    {
                    Byte[] target;
                    using (var stream = new MemoryStream()) {
                        using (var serializer = new FastReportSerializerSTD(stream)) {
                            serializer.Serialize(Body);
                            }
                        stream.Position = 0;
                        target = stream.ToArray();
                        }
                    if (!body.SequenceEqual(target))
                        {
                        File.WriteAllBytes($"{Label}.frx",body);
                        File.WriteAllBytes($"{Label}.frz",target);
                        }
                    }
                catch
                    {
                    File.WriteAllBytes($"{Label}.frx",body);
                    throw;
                    }
                #endif
                }
            }
        #endregion

        #region M:WriteXml(ISqlXmlWriter)
        /// <summary>Converts an object into its XML representation.</summary>
        /// <param name="writer">The <see cref="T:BinaryStudio.SqlServer.Infrastructure.ISqlXmlWriter"/> stream to which the object is serialized.</param>
        public override void WriteXml(ISqlXmlWriter writer) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            using (writer.ElementGroup("Report",URI_META)) {
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
                writer.ScheduleNewLineForNextAttribute().WriteReference(nameof(State),State);
                writer.WriteAttribute(nameof(ISO),ISO);
                writer.WriteCData(nameof(Name),URI_META,Name);
                writer.WriteCData(nameof(Description),URI_META,Description);
                writer.WriteCData(nameof(Options),URI_META,Options);
                if (Body != null) {
                    using (writer.ElementGroup("Body",URI_META)) {
                        using (var serializer = new FastReportSerializerEXT(writer)) {
                            serializer.Serialize(Body);
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

        [UsedImplicitly][SqlObjectFieldMapping("REPORT")][TypeConverter(typeof(SqlArrayConverter))] private Byte[] body;
        }
    }