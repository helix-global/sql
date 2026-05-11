using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Windows.Media;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;
    public class Interface : PDBObject
        {
        public IList<InterfaceItem> Items { get; } = EmptyArray<InterfaceItem>.List;
        [UsedImplicitly][Field("LABEL")]        public String Label { get; }
        [UsedImplicitly][Field("NAME")]         public String Name { get; }
        [UsedImplicitly][Field("OID")]          public Int32 OID { get; }
        [UsedImplicitly][Field("GID")]          public Guid UUID { get; }
        [UsedImplicitly][Field("S_CDT")]        public DateTime? CreatedDate  { get; }
        [UsedImplicitly][Field("S_MDT")]        public DateTime? ModifiedDate { get; }
        [UsedImplicitly][Field("REMARK")]       public String Description { get; }
        [UsedImplicitly][Field("POSORDER")]     public Int32? PositionOrder { get; }
        [UsedImplicitly][Field("ADMAUTOLOAD")]  public Boolean? LoadOnAdminAccount { get; }
        [UsedImplicitly][Field("MODULEOID")]    public Module Module { get; }
        [UsedImplicitly][Field("S_CR")]         public PDBUser CreatedBy  { get; }
        [UsedImplicitly][Field("S_MR")]         public PDBUser ModifiedBy { get; }
        [UsedImplicitly][Field("ONLYFIFQUERY")] public Query OnlyIfQuery { get; }
        [UsedImplicitly][Field("HIDEIFQUERY")]  public Query HideIfQuery { get; }
        public Color? Color { get; }

        #region ctor{DataRow,IServiceProvider,IDictionary<Int32,IList<DataRow>>}
        internal Interface(DataRow source,IServiceProvider service,IDictionary<Int32,IList<DataRow>> items)
            :base(source,service)
            {
            Color = (Color?)colors.ConvertTo(source["WSBCOLOR"],typeof(Color));

            var intfP = new List<InterfaceItem>();
            try
                {
                var intfI = new Dictionary<Int32,InterfaceItem>();
                if (items.TryGetValue(OID,out var rows)) {
                    foreach (var row in rows) {
                        var o = new InterfaceItem(row,service);
                        intfI[o.OID] = o;
                        }
                    }

                foreach (var item in intfI.Values.OrderBy(i=>i.Caption)) {
                    var parent_oid = item.ParentOID;
                    if (parent_oid == null) {
                        intfP.Add(item);
                        }
                    else
                        {
                        intfI[item.ParentOID.Value].Children.Add(item);
                        }
                    }
                }
            finally
                {
                Items = intfP.AsReadOnly();
                }
            }
        #endregion

        #region M:WriteXml(ISqlXmlWriter)
        /// <summary>Converts an object into its XML representation.</summary>
        /// <param name="writer">The <see cref="T:BinaryStudio.SqlServer.Infrastructure.ISqlXmlWriter"/> stream to which the object is serialized.</param>
        public override void WriteXml(ISqlXmlWriter writer) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            using (writer.ElementGroup("Interface",URI_META)) {
                writer.WriteAttribute("xmlns","xsi",null,URI_XSINIL);
                writer.WriteAttribute("xmlns","",null,URI_META);
                writer.ScheduleNewLineForNextAttribute().WriteAttribute(nameof(Label),Label);
                writer.WriteAttribute(nameof(OID),OID);
                writer.WriteAttribute(nameof(UUID),UUID);
                writer.ScheduleNewLineForNextAttribute().WriteAttribute(nameof(CreatedDate),CreatedDate);
                writer.WriteAttribute(nameof(ModifiedDate),ModifiedDate);
                writer.ScheduleNewLineForNextAttribute().WriteReference(nameof(CreatedBy),CreatedBy);
                writer.ScheduleNewLineForNextAttribute().WriteReference(nameof(ModifiedBy),ModifiedBy);
                writer.ScheduleNewLineForNextAttribute().WriteReference(nameof(Module),Module);
                writer.ScheduleNewLineForNextAttribute().WriteReference(nameof(OnlyIfQuery),OnlyIfQuery);
                writer.ScheduleNewLineForNextAttribute().WriteReference(nameof(HideIfQuery),HideIfQuery);
                writer.ScheduleNewLineForNextAttribute();
                writer.WriteAttribute(nameof(PositionOrder),PositionOrder);
                writer.WriteAttribute(nameof(Color),Color,colors);
                writer.WriteAttribute(nameof(LoadOnAdminAccount),LoadOnAdminAccount);
                writer.StopScheduleNewLineForNextAttribute();
                writer.WriteCData(nameof(Name),URI_META,Name);
                writer.WriteCData(nameof(Description),URI_META,Description);
                if (Items.Any()) {
                    using (writer.ElementGroup("Items",URI_META)) {
                        foreach (var item in Items) {
                            item.WriteXml(writer);
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

        private static readonly SqlColorConverter colors = new SqlColorConverter();
        }
    }