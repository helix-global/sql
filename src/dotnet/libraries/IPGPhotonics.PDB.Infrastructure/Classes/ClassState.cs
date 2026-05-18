using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;
using System;
using System.ComponentModel;
using System.Data;
using System.Windows.Media;

namespace IPGPhotonics.PDB.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [TypeConverter(typeof(ObjectConverter<ClassState>))]
    public class ClassState : PDBObject
        {
        [UsedImplicitly][Field("OID")]         public Int32 OID { get; }
        [UsedImplicitly][Field("NAME")]        public String Name { get; }
        [UsedImplicitly][Field("DESCRIPTION")] public String Description { get; }
        [UsedImplicitly][Field("S_CDT")]       public DateTime? CreatedDate  { get; }
        [UsedImplicitly][Field("S_MDT")]       public DateTime? ModifiedDate { get; }
        [UsedImplicitly][Field("GID")]         public Guid UUID { get; }
        [UsedImplicitly][Field("S_CR")]        public User CreatedBy  { get; }
        [UsedImplicitly][Field("S_MR")]        public User ModifiedBy { get; }
        public ReadOnlyState ReadOnlyState { get; }
        public DeletionStateMode? EnableDeleting { get; }
        public String Label { get; }
        public Color? Color { get; }

        #region ctor{DataRow,IServiceProvider}
        internal ClassState(DataRow source,IServiceProvider service)
            :base(source,service)
            {
            ReadOnlyState  = PropE(source["READONLYSTATE"],ReadOnlyState.Editable);
            EnableDeleting = PropE<DeletionStateMode>(source["YESDEL"]);
            Label = DecodeLanguageString(Name);
            Color = (Color?)colors.ConvertTo(source["STATECOLOR"],typeof(Color));
            }
        #endregion

        #region M:WriteXml(ISqlXmlWriter)
        /// <summary>Converts an object into its XML representation.</summary>
        /// <param name="writer">The <see cref="T:BinaryStudio.SqlServer.Infrastructure.ISqlXmlWriter"/> stream to which the object is serialized.</param>
        public override void WriteXml(ISqlXmlWriter writer) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            using (writer.ElementGroup("State",URI_META)) {
                writer.ScheduleNewLineForNextAttribute().WriteAttribute(nameof(OID),OID);
                writer.WriteAttribute(nameof(UUID),UUID);
                writer.ScheduleNewLineForNextAttribute().WriteAttribute(nameof(CreatedDate),CreatedDate);
                writer.WriteAttribute(nameof(ModifiedDate),ModifiedDate);
                writer.ScheduleNewLineForNextAttribute().WriteReference(nameof(CreatedBy),CreatedBy);
                writer.ScheduleNewLineForNextAttribute().WriteReference(nameof(ModifiedBy),ModifiedBy);
                writer.ScheduleNewLineForNextAttribute();
                writer.WriteAttribute(nameof(ReadOnlyState),ReadOnlyState);
                writer.WriteAttribute(nameof(Color),Color,colors);
                writer.WriteAttribute(nameof(EnableDeleting),EnableDeleting);
                writer.WriteCData(nameof(Name),URI_META,Name);
                writer.WriteCData(nameof(Description),URI_META,Description);
                }
            }
        #endregion
        #region M:ToString():String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return $"{Name}";
            }
        #endregion

        private static readonly SqlColorConverter colors = new SqlColorConverter();
        }
    }