using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;
using static BinaryStudio.SqlServer.Infrastructure.SqlXmlWriterAttributeOptions;

namespace IPGPhotonics.PDB.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [TypeConverter(typeof(ObjectConverter<Class>))]
    public class Class : PDBObject
        {
        public IDictionary<Int32,ClassState> States { get; }
        [UsedImplicitly][Field("OID")]                 public Int32 OID { get; }
        [UsedImplicitly][Field("NAME")]                public String Name { get; }
        [UsedImplicitly][Field("LABEL")]               public String Label { get; }
        [UsedImplicitly][Field("REMARK")]              public String Description { get; }
        [UsedImplicitly][Field("DOPTION")]             public String Options { get; }
        [UsedImplicitly][Field("S_CDT")]               public DateTime? CreatedDate  { get; }
        [UsedImplicitly][Field("S_MDT")]               public DateTime? ModifiedDate { get; }
        [UsedImplicitly][Field("GID")]                 public Guid UUID { get; }
        [UsedImplicitly][Field("SPELLCHECKER")]        public Boolean SpellCheckingDisabled { get; }
        [UsedImplicitly][Field("SQLFILTER")]           public String SqlFilterClauseExpression { get; }
        [UsedImplicitly][Field("FACCESS")]             public String SqlFineAccessExpression { get; }
        [UsedImplicitly][Field("FACCESSNEW")]          public String SqlFineAccessExpressionForNewDocument { get; }
        [UsedImplicitly][Field("SQLCLAUSEOPTION")]     public String SqlOptionClauseExpression { get; }
        [UsedImplicitly][Field("RENTITYSQLFILTER")]    public String SqlEntityFilterClauseExpressionOverride { get; }
        [UsedImplicitly][Field("SQLPROLOG")]           public String SqlProlog { get; }
        [UsedImplicitly][Field("ACCESSLEVEL")]         public String AccessLevel { get; }
        [UsedImplicitly][Field("NEWNAME")]             public String NewNameCaption { get; }
        [UsedImplicitly][Field("NAMEMASK")]            public String NameMask { get; }
        [UsedImplicitly][Field("DEFAULTPERIOD")]       public DatePeriodType? DefaultListPeriod { get; }
        [UsedImplicitly][Field("DEFAULTPERIODCUSTOM")] public Int32? DefaultListPeriodCustom { get; }
        [UsedImplicitly][Field("S_CR")]                public PDBUser CreatedBy  { get; }
        [UsedImplicitly][Field("S_MR")]                public PDBUser ModifiedBy { get; }
        [UsedImplicitly][Field("MODULEOID")]           public Module Module { get; }
        [UsedImplicitly][Field("ENTITYOID")]           public Entity Entity { get; }
        [UsedImplicitly][Field("LIVEUNIT")]            public Unit LiveUnit { get; }
        [UsedImplicitly][Field("LISTUNIT")]            public Unit ListUnit { get; }
        [UsedImplicitly][Field("OPENUNITOID")]         public Unit OpenUnit { get; }
        [UsedImplicitly][Field("FAQUERY")]             public Query FineAccessQuery { get; }
        [UsedImplicitly][Field("FOLDERSQOID")]         public Query FoldersQuery { get; }
        public Boolean DisableDirectAdd { get; }
        public Boolean DisableDirectDelete { get; }
        public Boolean DisableCopy { get; }
        public Boolean AlwaysReadOnly { get; }

        #region ctor{DataRow,IServiceProvider,IDictionary<Int32,IList<DataRow>>}
        internal Class(DataRow source,IServiceProvider service,
            IDictionary<Int32,IList<DataRow>> states)
            :base(source,service)
            {
            DisableDirectAdd    = PropB(source["NOLISTADD"],false);
            DisableDirectDelete = PropB(source["NOLISTDEL"],false);
            DisableCopy         = PropB(source["NOCOPY"],false);
            AlwaysReadOnly      = PropB(source["NOEDITABLE"],false);
            States = new Dictionary<Int32,ClassState>();
            try
                {
                if (states.TryGetValue(OID,out var rows)) {
                    foreach (var row in rows) {
                        var o = new ClassState(row,service);
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
                writer.ScheduleNewLineForNextAttribute().WriteAttribute(nameof(Label),Label);
                writer.WriteAttribute(nameof(OID),OID);
                writer.WriteAttribute(nameof(UUID),UUID);
                writer.ScheduleNewLineForNextAttribute().WriteAttribute(nameof(CreatedDate),CreatedDate);
                writer.WriteAttribute(nameof(ModifiedDate),ModifiedDate);
                writer.ScheduleNewLineForNextAttribute().WriteReference(nameof(CreatedBy),CreatedBy);
                writer.ScheduleNewLineForNextAttribute().WriteReference(nameof(ModifiedBy),ModifiedBy);
                writer.ScheduleNewLineForNextAttribute().WriteReference(nameof(Module),Module);
                writer.ScheduleNewLineForNextAttribute().WriteReference(nameof(Entity),Entity,ForceNewLine);
                writer.ScheduleNewLineForNextAttribute().WriteReference(nameof(LiveUnit),LiveUnit);
                writer.ScheduleNewLineForNextAttribute().WriteReference(nameof(ListUnit),ListUnit);
                writer.ScheduleNewLineForNextAttribute().WriteReference(nameof(OpenUnit),OpenUnit);
                writer.ScheduleNewLineForNextAttribute().WriteReference(nameof(FineAccessQuery),FineAccessQuery);
                writer.ScheduleNewLineForNextAttribute().WriteReference(nameof(FoldersQuery),FoldersQuery);
                writer.ScheduleNewLineForNextAttribute().WriteAttribute(nameof(DefaultListPeriod),DefaultListPeriod);
                writer.WriteAttribute(nameof(DefaultListPeriodCustom),DefaultListPeriodCustom);
                if (DisableDirectAdd || DisableDirectDelete || DisableCopy) {
                    writer.ScheduleNewLineForNextAttribute();
                    writer.WriteAttribute(nameof(DisableDirectAdd),DisableDirectAdd);
                    writer.WriteAttribute(nameof(DisableDirectDelete),DisableDirectDelete);
                    writer.WriteAttribute(nameof(DisableCopy),DisableCopy);
                    }
                writer.ScheduleNewLineForNextAttribute();
                writer.WriteAttribute(nameof(AccessLevel),AccessLevel);
                writer.WriteAttribute(nameof(AlwaysReadOnly),AlwaysReadOnly);
                writer.WriteAttribute(nameof(SpellCheckingDisabled),SpellCheckingDisabled);
                writer.WriteCData(nameof(Name),URI_META,Name);
                writer.WriteCData(nameof(NameMask),URI_META,NameMask);
                writer.WriteCData(nameof(Options),URI_META,Options);
                writer.WriteCData(nameof(Description),URI_META,Description);
                writer.WriteCData(nameof(SqlFilterClauseExpression),URI_META,SqlFilterClauseExpression);
                writer.WriteCData(nameof(SqlFineAccessExpression),URI_META,SqlFineAccessExpression);
                writer.WriteCData(nameof(SqlFineAccessExpressionForNewDocument),URI_META,SqlFineAccessExpressionForNewDocument);
                writer.WriteCData(nameof(SqlEntityFilterClauseExpressionOverride),URI_META,SqlEntityFilterClauseExpressionOverride);
                writer.WriteCData(nameof(SqlOptionClauseExpression),URI_META,SqlOptionClauseExpression);
                writer.WriteCData(nameof(SqlProlog),URI_META,SqlProlog);
                writer.WriteCData(nameof(NewNameCaption),URI_META,NewNameCaption);
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