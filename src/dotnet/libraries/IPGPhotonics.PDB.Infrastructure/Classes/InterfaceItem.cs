using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;
    public class InterfaceItem : PDBObject
        {
        [UsedImplicitly][Field("OID")]            public Int32 OID { get; }
        [UsedImplicitly][Field("GID")]            public Guid UUID { get; }
        [UsedImplicitly][Field("PARENTOID")]      public Int32? ParentOID { get; }
        [UsedImplicitly][Field("CAPTION")]        public String Caption { get; }
        [UsedImplicitly][Field("POSORDER")]       public Int32? PositionOrder { get; }
        [UsedImplicitly][Field("S_CDT")]          public DateTime? CreatedDate  { get; }
        [UsedImplicitly][Field("S_MDT")]          public DateTime? ModifiedDate { get; }
        [UsedImplicitly][Field("OPTIONS")]        public String Options { get; }
        [UsedImplicitly][Field("COMMAND")]        public String Command { get; }
        [UsedImplicitly][Field("WORKSPACEGROUP")] public String WorkspaceGroup { get; }
        [UsedImplicitly][Field("SHORTCUT")]       public String ShortCut { get; }
        [UsedImplicitly][Field("S_CR")]           public PDBUser CreatedBy  { get; }
        [UsedImplicitly][Field("S_MR")]           public PDBUser ModifiedBy { get; }
        [UsedImplicitly][Field("ONLYIFQUERY")]    public Query OnlyIfQuery { get; }
        [UsedImplicitly][Field("ONLY4GROUP")]     public PDBUser OnlyIfGroup { get; }
        [UsedImplicitly][Field("WORKSPACECOUNT")] public Query WorkspaceCounterQuery { get; }
        [UsedImplicitly][Field("CLASSOID")]       public Class Class { get; }
        [UsedImplicitly][Field("REPORTOID")]      public Report Report { get; }
        [UsedImplicitly][Field("VIEWOID")]        public View View { get; }
        [UsedImplicitly][Field("OPEROID")]        public Operation Operation { get; }
        public IList<InterfaceItem> Children { get; } = new List<InterfaceItem>();

        #region ctor{DataRow,IServiceProvider}
        internal InterfaceItem(DataRow source,IServiceProvider service)
            :base(source,service)
            {
            }
        #endregion
        #region M:WriteXml(ISqlXmlWriter)
        /// <summary>Converts an object into its XML representation.</summary>
        /// <param name="writer">The <see cref="T:BinaryStudio.SqlServer.Infrastructure.ISqlXmlWriter"/> stream to which the object is serialized.</param>
        public override void WriteXml(ISqlXmlWriter writer) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            using (writer.ElementGroup("Item",URI_META)) {
                writer.WriteAttribute(nameof(OID),OID);
                writer.WriteAttribute(nameof(UUID),UUID);
                writer.ScheduleNewLineForNextAttribute().WriteAttribute(nameof(CreatedDate),CreatedDate);
                writer.WriteAttribute(nameof(ModifiedDate),ModifiedDate);
                writer.ScheduleNewLineForNextAttribute().WriteReference(nameof(CreatedBy),CreatedBy);
                writer.ScheduleNewLineForNextAttribute().WriteReference(nameof(ModifiedBy),ModifiedBy);
                writer.ScheduleNewLineForNextAttribute().WriteReference(nameof(Class),Class);
                writer.ScheduleNewLineForNextAttribute().WriteReference(nameof(OnlyIfQuery),OnlyIfQuery);
                writer.ScheduleNewLineForNextAttribute().WriteReference(nameof(OnlyIfGroup),OnlyIfGroup);
                writer.ScheduleNewLineForNextAttribute().WriteReference(nameof(WorkspaceCounterQuery),WorkspaceCounterQuery);
                writer.ScheduleNewLineForNextAttribute().WriteReference(nameof(Report),Report);
                writer.ScheduleNewLineForNextAttribute().WriteReference(nameof(View),View);
                writer.ScheduleNewLineForNextAttribute().WriteReference(nameof(Operation),Operation);
                writer.ScheduleNewLineForNextAttribute().WriteAttribute(nameof(Command),Command);
                writer.ScheduleNewLineForNextAttribute();
                writer.WriteAttribute(nameof(PositionOrder),PositionOrder);
                writer.WriteAttribute(nameof(ShortCut),ShortCut);
                writer.StopScheduleNewLineForNextAttribute();
                writer.WriteCData(nameof(Caption),URI_META,Caption);
                writer.WriteCData(nameof(WorkspaceGroup),URI_META,WorkspaceGroup);
                writer.WriteCData(nameof(Options),URI_META,Options);
                if (Children.Any()) {
                    using (writer.ElementGroup("Items",URI_META)) {
                        foreach (var item in Children) {
                            item.WriteXml(writer);
                            }
                        }
                    }
                }
            }
        #endregion
        }
    }